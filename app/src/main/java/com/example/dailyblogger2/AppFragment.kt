package com.example.dailyblogger2

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.*
import androidx.appcompat.content.res.AppCompatResources.getDrawable

import androidx.fragment.app.FragmentTransaction
import androidx.recyclerview.widget.DividerItemDecoration
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.google.android.material.floatingactionbutton.FloatingActionButton
import com.google.firebase.auth.ktx.auth
import com.google.firebase.database.*
import com.google.firebase.firestore.ktx.firestore
import com.google.firebase.ktx.Firebase
import com.google.firebase.storage.FirebaseStorage
import kotlinx.android.synthetic.main.fragment_app.*
import kotlinx.android.synthetic.main.fragment_register.*
import java.io.File
import java.util.*
import kotlin.collections.ArrayList

class AppFragment : Fragment() {
    private lateinit var image:ImageView
    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?,
    ): View? {
        // Inflate the layout for this fragment
        val view: View = inflater.inflate(R.layout.fragment_app, container, false)
        val logoutButton = view.findViewById<Button>(R.id.fragment_app_backButton)
        logoutButton.setOnClickListener {
            switchToMainPageFragment()
        }
        val addButton = view.findViewById<FloatingActionButton>(R.id.appFragment_addPostButton)
        addButton.setOnClickListener {
            switchToAddPostFragment()
        }

        image = view.findViewById(R.id.app_fragment_userPhoto)
        val rv = view.findViewById<RecyclerView>(R.id.allPosts)
        getData(rv)
        getUserPhoto()
        return view
    }

    private fun getUserPhoto(){
        val userEmail = Firebase.auth.currentUser?.email.toString()
        val storageRef = FirebaseStorage.getInstance().getReference().child("images/$userEmail")
        val localFile: File = File.createTempFile("$userEmail", "jpg")
        storageRef.getFile(localFile)
            .addOnSuccessListener {
                val bitmap:Bitmap = BitmapFactory.decodeFile(localFile.absolutePath)
                image.setImageBitmap(bitmap)
            }
    }

    private fun getData(rv: RecyclerView){
        val db=Firebase.firestore
        db.collection("posts").get().addOnSuccessListener {
            val posts = it.toObjects(Post::class.java) as ArrayList<Post>
            rv.adapter = PostsAdapter(posts)
            rv.layoutManager = LinearLayoutManager(requireContext())
            val itemDecoration = DividerItemDecoration(this.context,DividerItemDecoration.VERTICAL)
            context?.let { it1 -> getDrawable(it1, R.drawable.divider)?.let { it1 -> itemDecoration.setDrawable(it1) } }
            rv.addItemDecoration(itemDecoration)
        }
    }

    private fun switchToMainPageFragment() {
        val fragmentTransaction: FragmentTransaction? =
            activity?.supportFragmentManager?.beginTransaction()
        fragmentTransaction?.replace(R.id.main_activity_fragmentContainer, MainFragment())!!.addToBackStack("stozic")
        fragmentTransaction?.commit()
    }

    private fun switchToAddPostFragment() {
        val fragmentTransaction: FragmentTransaction? =
            activity?.supportFragmentManager?.beginTransaction()
        fragmentTransaction?.replace(R.id.main_activity_fragmentContainer, AddPostFragment())!!.addToBackStack("stozic")
        fragmentTransaction?.commit()
    }
}





