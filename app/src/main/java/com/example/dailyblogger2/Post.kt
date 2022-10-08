package com.example.dailyblogger2

import android.graphics.Bitmap

data class Post(
    var image: String? = null,
    var description: String? = null,
    var userName: String? = null,
    var userPhoto: String? = null
)