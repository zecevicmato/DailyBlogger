package com.example.dailyblogger2

import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.EditText
import android.widget.Toast
import androidx.fragment.app.FragmentTransaction
import com.google.firebase.auth.FirebaseAuth


class LoginFragment : Fragment() {


    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?,
    ): View? {
        // Inflate the layout for this fragment
        val view:View = inflater.inflate(R.layout.fragment_login, container, false)
        val loginButton = view.findViewById<Button>(R.id.fragment_login_loginButton)
        val mainPageButton = view.findViewById<Button>(R.id.fragment_login_mainPageButton)
        val userEmail = view.findViewById<EditText>(R.id.fragment_login_userEmail)
        val userPassword = view.findViewById<EditText>(R.id.fragment_login_userPassword)
        mainPageButton.setOnClickListener {
            switchToMainPageFragment()
        }

        loginButton.setOnClickListener {
            val email: String = userEmail.text.toString()
            val password: String = userPassword.text.toString()
            if(email.isEmpty() || password.isEmpty()){
                Toast.makeText(context,"Please enter correct email and password!", Toast.LENGTH_SHORT).show()
            }
            else{
                signIn(email, password)
            }
        }

        return view
    }

    private fun signIn(email: String,password: String) {
        FirebaseAuth.getInstance().signInWithEmailAndPassword(email,password)
            .addOnCompleteListener { task ->

                if (task.isSuccessful) {
                    Toast.makeText(context,
                        "You are logged in successfully.",
                        Toast.LENGTH_SHORT).show()

                    val fragmentTransaction: FragmentTransaction? =
                        activity?.supportFragmentManager?.beginTransaction()
                    fragmentTransaction?.replace(R.id.main_activity_fragmentContainer, AppFragment())!!.addToBackStack("stozic")
                    fragmentTransaction?.commit()
                }

            }
    }

    private fun switchToMainPageFragment() {
        val fragmentTransaction: FragmentTransaction? =
            activity?.supportFragmentManager?.beginTransaction()
        fragmentTransaction?.replace(R.id.main_activity_fragmentContainer, MainFragment())!!.addToBackStack("stozic")
        fragmentTransaction?.commit()
    }
}