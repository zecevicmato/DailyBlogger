package com.example.dailyblogger2

import android.app.Activity
import android.app.Activity.RESULT_OK
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.provider.MediaStore
import android.text.TextUtils
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.EditText
import android.widget.ImageView
import android.widget.Toast
import androidx.fragment.app.FragmentTransaction
import com.example.dailyblogger2.AddPostFragment.Companion.IMAGE_REQUEST_CODE
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.ktx.auth
import com.google.firebase.database.FirebaseDatabase
import com.google.firebase.firestore.ktx.firestore
import com.google.firebase.ktx.Firebase
import com.google.firebase.storage.FirebaseStorage
import de.hdodenhof.circleimageview.CircleImageView
import kotlinx.android.synthetic.main.fragment_register.*
import java.util.*
import kotlin.math.log

class RegisterFragment : Fragment() {
    companion object {
        const val IMAGE_REQUEST_CODE = 100
    }
    private var userName = ""
    private var userEmail = ""
    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?,
    ): View? {
        val view: View = inflater.inflate(R.layout.fragment_register, container, false)
        val register_userName=view.findViewById<EditText>(R.id.fragment_register_userName)
        val register_userEmail=view.findViewById<EditText>(R.id.fragment_register_userEmail)

        val registerButton = view.findViewById<Button>(R.id.fragment_register_registerButton)
        val mainPageButton = view.findViewById<Button>(R.id.fragment_register_mainPageButton)
        mainPageButton.setOnClickListener {
            switchToMainPageFragment()
        }
        registerButton.setOnClickListener {
            userName = register_userName.text.toString()
            userEmail = register_userEmail.text.toString()
            performRegister()
            val fragmentTransaction: FragmentTransaction? =
                activity?.supportFragmentManager?.beginTransaction()
            fragmentTransaction?.replace(R.id.main_activity_fragmentContainer, AppFragment())!!
                .addToBackStack("stozic")
            fragmentTransaction?.commit()
        }

        val userPhoto = view.findViewById<CircleImageView>(R.id.fragment_register_userPhoto)
        userPhoto.setOnClickListener {
            pickImageGallery()
        }
        return view
    }

    private fun pickImageGallery() {
        val intent = Intent(Intent.ACTION_PICK)
        intent.type = "image/*"
        startActivityForResult(intent, IMAGE_REQUEST_CODE)
    }

    var selectedPhotoUri: Uri? = null
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == IMAGE_REQUEST_CODE && resultCode == RESULT_OK) {
            val userPhoto = view?.findViewById<ImageView>(R.id.fragment_register_userPhoto)
            if (userPhoto != null) {
                with(userPhoto) { setImageURI(data?.data) }
            }
            selectedPhotoUri = data?.data
        }
    }

    private fun switchToMainPageFragment() {
        val fragmentTransaction: FragmentTransaction? =
            activity?.supportFragmentManager?.beginTransaction()
        fragmentTransaction?.replace(R.id.main_activity_fragmentContainer, MainFragment())!!
            .addToBackStack("stozic")
        fragmentTransaction?.commit()
    }

    private fun performRegister() {
        val email = view?.findViewById<EditText>(R.id.fragment_register_userEmail)?.text.toString()
        val password =
            view?.findViewById<EditText>(R.id.fragment_register_userPassword)?.text.toString()
        val userName =
            view?.findViewById<EditText>(R.id.fragment_register_userName)?.text.toString()
        if (email.isEmpty() || password.isEmpty()) {
            Toast.makeText(context, "Please enter email or pass.", Toast.LENGTH_SHORT).show()
            return
        }

        FirebaseAuth.getInstance().createUserWithEmailAndPassword(email, password)
            .addOnCompleteListener {
                if (it.isSuccessful) {
                    val user = User(userName, email, password)
                    val db = Firebase.firestore
                    db.collection("users").add(user)
                    uploadImageToFirebaseStorage()
                }
            }

    }

    private fun uploadImageToFirebaseStorage() {
        if (selectedPhotoUri == null) return
        val filename = userEmail
        val ref = FirebaseStorage.getInstance().getReference("/images/$filename")
        ref.putFile(selectedPhotoUri!!)
            .addOnSuccessListener {
                ref.downloadUrl.addOnSuccessListener {
                    saveUserToDatabase(it.toString())
                }
            }
    }

    private fun saveUserToDatabase(userPhoto: String) {
        val uid = Firebase.auth.uid
        val db = Firebase.firestore
        val user = User(uid,userName, userPhoto)
        db.collection("users").add(user)
    }
}



