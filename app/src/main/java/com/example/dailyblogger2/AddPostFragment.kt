package com.example.dailyblogger2

import android.app.Activity
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Bundle
import android.util.Log
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.EditText
import android.widget.ImageView
import android.widget.TextView
import androidx.fragment.app.FragmentTransaction
import com.google.android.gms.tasks.Task
import com.google.android.material.floatingactionbutton.FloatingActionButton
import com.google.firebase.auth.ktx.auth
import com.google.firebase.firestore.QuerySnapshot
import com.google.firebase.firestore.ktx.firestore
import com.google.firebase.ktx.Firebase
import com.google.firebase.storage.FirebaseStorage
import java.io.File

class AddPostFragment : Fragment() {
    private var selectedPhotoUri: Uri?=null
    companion object{
        const val IMAGE_REQUEST_CODE=100
    }
    private var bitmap:Bitmap? =null
    private var description = ""
    private var userEmail : String? = null
    private lateinit var userPhoto : ImageView
    private lateinit var userName : TextView

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?, ): View? {

        val view:View = inflater.inflate(R.layout.fragment_add_post, container, false)

        val fragment_add_post_description = view.findViewById<EditText>(R.id.fragment_add_post_description)

        val backButton = view.findViewById<FloatingActionButton>(R.id.fragment_add_post_backButton)

        backButton.setOnClickListener {
            switchToAppFragment()
        }

        val uploadButton = view.findViewById<FloatingActionButton>(R.id.fragment_add_post_addButton)
        uploadButton.setOnClickListener{
            description = fragment_add_post_description.text.toString()
            performUpload()
        }


        val postPhoto = view.findViewById<ImageView>(R.id.fragment_add_post_postPhoto)
        postPhoto.setOnClickListener {
            pickImageGallery()
        }

        getUser()

        userPhoto = view.findViewById(R.id.fragment_add_post_userPhoto)
        userName = view.findViewById<TextView>(R.id.fragment_add_post_userName)

        getUserPhoto()
        return view
    }

    private fun performUpload() {
        view?.findViewById<EditText>(R.id.fragment_add_post_description)?.text.toString()

        uploadImageToFirebaseStorage()
        val fragmentTransaction: FragmentTransaction? =
            activity?.supportFragmentManager?.beginTransaction()
        fragmentTransaction?.replace(R.id.main_activity_fragmentContainer, AppFragment())!!.addToBackStack("stozic")
        fragmentTransaction?.commit()
    }

    private fun uploadImageToFirebaseStorage() {
        if (selectedPhotoUri == null) return
        val filename = userEmail
        val ref = FirebaseStorage.getInstance().getReference("/posts/$filename")
        ref.putFile(selectedPhotoUri!!)
            .addOnSuccessListener {
                ref.downloadUrl.addOnSuccessListener {
                    savePostToDatabase(it.toString(),)
                }
            }
    }

    private fun savePostToDatabase(image: String) {
        val userName = userName.text.toString()
        val userPhoto = userEmail
        val db = Firebase.firestore
        val post = Post(image,description,userName,userPhoto)
        db.collection("posts").add(post)
    }

    private fun getUser() {
       val response = getCurrentUser()
       response.addOnSuccessListener { snapshot ->
           val users = snapshot.toObjects(User::class.java)
           for (user in users) {
               if (user?.userName.toString()
                       .contains(Firebase.auth.currentUser?.email.toString())
               ) {
                   userName.text=user.uid
                   userEmail = user.userName
               }
           }
       }
   }

   fun getCurrentUser(): Task<QuerySnapshot> {
       val db = Firebase.firestore
       return db.collection("users")
           .get()
   }

    private fun getUserPhoto(){
        val userEmail = Firebase.auth.currentUser?.email.toString()
        val storageRef = FirebaseStorage.getInstance().getReference().child("images/$userEmail")
        val localFile: File = File.createTempFile("$userEmail", "jpg")
        storageRef.getFile(localFile)
            .addOnSuccessListener {
                val photoBitmap: Bitmap = BitmapFactory.decodeFile(localFile.absolutePath)
                userPhoto.setImageBitmap(photoBitmap)
                bitmap=photoBitmap
            }
    }

    private fun pickImageGallery() {
        val intent = Intent(Intent.ACTION_PICK)
        intent.type="image/*"
        startActivityForResult(intent, AddPostFragment.IMAGE_REQUEST_CODE)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if(requestCode== AddPostFragment.IMAGE_REQUEST_CODE && resultCode == Activity.RESULT_OK){
            val postPhoto= view?.findViewById<ImageView>(R.id.fragment_add_post_postPhoto)
            if (postPhoto != null) {
                with(postPhoto) {
                    setImageURI(data?.data)
                    selectedPhotoUri = data?.data
                }
            }
        }
    }

    private fun switchToAppFragment() {
        val fragmentTransaction: FragmentTransaction? =
            activity?.supportFragmentManager?.beginTransaction()
        fragmentTransaction?.replace(R.id.main_activity_fragmentContainer, AppFragment())!!.addToBackStack("stozic")
        fragmentTransaction?.commit()
    }
}