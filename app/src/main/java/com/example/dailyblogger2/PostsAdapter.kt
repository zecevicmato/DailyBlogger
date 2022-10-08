package com.example.dailyblogger2

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.google.firebase.auth.ktx.auth
import com.google.firebase.ktx.Firebase
import com.google.firebase.storage.FirebaseStorage
import java.io.File

class PostsAdapter(val items: ArrayList<Post>) :
    RecyclerView.Adapter<RecyclerView.ViewHolder>() {
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return PostViewHolder(LayoutInflater.from(parent.context).inflate(R.layout.post_layout, parent, false))
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        when(holder) {
            is PostViewHolder -> {
                holder.bind(items[position])
            }
        }
    }

    override fun getItemCount(): Int {
        return items.size
    }

    inner class PostViewHolder (
        itemView: View
    ): RecyclerView.ViewHolder(itemView) {
        private val userPhoto: ImageView =
            itemView.findViewById(R.id.post_userPhoto)
        private val userName: TextView =
            itemView.findViewById(R.id.post_userName)
        private val postDescription: TextView =
            itemView.findViewById(R.id.post_description)
        private val postImage: ImageView =
            itemView.findViewById(R.id.post_image)

        fun bind(posts: Post) {
            Glide
                .with(itemView.context)
                .load(posts.image)
                .into(postImage)

            if(!posts.userPhoto.isNullOrEmpty()){
                getUserPhoto(posts.userPhoto)
            }

            userName.text = posts.userName
            postDescription.text = posts.description
        }

        private fun getUserPhoto(email:String?){
            val storageRef = FirebaseStorage.getInstance().getReference().child("images/$email")
            val localFile: File = File.createTempFile("$email", "jpg")
            storageRef.getFile(localFile)
                .addOnSuccessListener {
                    val photoBitmap: Bitmap = BitmapFactory.decodeFile(localFile.absolutePath)
                    userPhoto.setImageBitmap(photoBitmap)

                }
        }
    }

}