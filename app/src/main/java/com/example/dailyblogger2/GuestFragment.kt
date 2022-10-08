package com.example.dailyblogger2

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.ImageView
import androidx.appcompat.content.res.AppCompatResources
import androidx.fragment.app.FragmentTransaction
import androidx.recyclerview.widget.DividerItemDecoration
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.google.firebase.auth.ktx.auth
import com.google.firebase.firestore.ktx.firestore
import com.google.firebase.ktx.Firebase
import com.google.firebase.storage.FirebaseStorage
import java.io.File


class GuestFragment : Fragment() {
    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?,
    ): View? {
        // Inflate the layout for this fragment
        val view:View=inflater.inflate(R.layout.fragment_guest, container, false)
        val backButton = view.findViewById<Button>(R.id.fragment_guest_backButton)
        backButton.setOnClickListener { switchToMainPageFragment() }

        val rv = view.findViewById<RecyclerView>(R.id.allPosts)
        getData(rv)
        return view
    }
    private fun getData(rv: RecyclerView){
        val db= Firebase.firestore
        db.collection("posts").get().addOnSuccessListener {
            val posts = it.toObjects(Post::class.java) as ArrayList<Post>
            rv.adapter = PostsAdapter(posts)
            rv.layoutManager = LinearLayoutManager(requireContext())

            val itemDecoration = DividerItemDecoration(this.context, DividerItemDecoration.VERTICAL)
            context?.let { it1 -> AppCompatResources.getDrawable(it1, R.drawable.divider)?.let { it1 -> itemDecoration.setDrawable(it1) } }
            rv.addItemDecoration(itemDecoration)
        }
    }

    private fun switchToMainPageFragment() {
        val fragmentTransaction: FragmentTransaction? =
            activity?.supportFragmentManager?.beginTransaction()
        fragmentTransaction?.replace(R.id.main_activity_fragmentContainer, MainFragment())!!
            .addToBackStack("stozic")
        fragmentTransaction?.commit()
    }
}