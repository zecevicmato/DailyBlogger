package com.example.dailyblogger2

import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import androidx.fragment.app.FragmentTransaction


class MainFragment : Fragment() {
    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?,
    ): View? {
        // Inflate the layout for this fragment
        val view:View = inflater.inflate(R.layout.fragment_main, container, false)
        val loginButton = view.findViewById<Button>(R.id.fragment_main_loginButton)
        val registerButton = view.findViewById<Button>(R.id.fragment_main_registerButton)
        val guestButton = view.findViewById<Button>(R.id.fragment_main_guestButton)
        guestButton.setOnClickListener { switchToGuestFragment() }
        loginButton.setOnClickListener {
            switchToLoginFragment()
        }
        registerButton.setOnClickListener {
            switchToRegisterFragment()
        }
        return view
    }

    private fun switchToGuestFragment() {
        val fragmentTransaction: FragmentTransaction? =
            activity?.supportFragmentManager?.beginTransaction()
        fragmentTransaction?.replace(R.id.main_activity_fragmentContainer, GuestFragment())!!.addToBackStack("back")
        fragmentTransaction?.commit()
    }


    private fun switchToRegisterFragment() {
        val fragmentTransaction: FragmentTransaction? =
            activity?.supportFragmentManager?.beginTransaction()
        fragmentTransaction?.replace(R.id.main_activity_fragmentContainer, RegisterFragment())!!.addToBackStack("back")
        fragmentTransaction?.commit()
    }

    private fun switchToLoginFragment() {
        val fragmentTransaction: FragmentTransaction? =
            activity?.supportFragmentManager?.beginTransaction()
        fragmentTransaction?.replace(R.id.main_activity_fragmentContainer, LoginFragment())!!.addToBackStack("back")
        fragmentTransaction?.commit()
    }

}