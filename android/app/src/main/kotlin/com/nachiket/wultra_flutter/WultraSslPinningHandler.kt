package com.nachiket.wultra_flutter

import android.content.Context
import android.os.Build
import androidx.annotation.RequiresApi
import com.wultra.android.sslpinning.CertStore
import com.wultra.android.sslpinning.CertStoreConfiguration
import com.wultra.android.sslpinning.UpdateMode
import com.wultra.android.sslpinning.UpdateResult
import com.wultra.android.sslpinning.UpdateType
import com.wultra.android.sslpinning.integration.DefaultUpdateObserver
import com.wultra.android.sslpinning.integration.powerauth.powerAuthCertStore
import java.net.URL
import java.util.Base64


class WultraSslPinningHandler(private val context: Context) {

    private var infoText: String = ""
    private lateinit var certStore: CertStore
    private val serviceUrl = "https://mus.adwebtech.com:8080/app/init?appName=wultra_flutter_android"
    private val appPublicKey = "BKyYKYc8xtEwXdoQ19xaoCrcjFOiXlZO0GsfWOAlP5MxmhGjVY/+CjfZdHEQKaRs6XtP1CGDqWQxSYGI9qzkktI="
    @RequiresApi(Build.VERSION_CODES.O)
    private val publicKey: ByteArray = Base64.getDecoder().decode(appPublicKey)

    @RequiresApi(Build.VERSION_CODES.O)
    fun initCertStore(): Boolean {
        return try {
            val configuration = CertStoreConfiguration.Builder(
                serviceUrl = URL(serviceUrl),
                publicKey = publicKey
            )
                .useChallenge(true)
                .build()
            certStore = CertStore.powerAuthCertStore(configuration, context)
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    fun getUpdateOnFingerprints(): String {
        return try {
            certStore.update(UpdateMode.DEFAULT, object : DefaultUpdateObserver() {
                override fun continueExecution() {
                    // Certstore is likely up-to-date, you can resume execution of your code.
                    infoText = "msg success"
                    println("info:: Wultra continueExecution")
                    println(infoText)
                }

                override fun handleFailedUpdate(type: UpdateType, result: UpdateResult) {
                    // There was an error during the update, present an error to the user.
                    println("info:: Wultra handleFailedUpdate")
                    println("....UpdateType -> $type")
                    println("....UpdateResult -> $result")
                }

                override fun onUpdateStarted(type: UpdateType) {
                    super.onUpdateStarted(type)
                    println("info:: Wultra onUpdateStarted")
                    println("....UpdateType -> $type")

                }

                override fun onUpdateFinished(type: UpdateType, result: UpdateResult) {
                    super.onUpdateFinished(type, result)
                    println("info:: Wultra onUpdateFinished")
                    println("....UpdateType -> $type")
                    println("....UpdateResult -> $result")
                }
            })
            infoText
        } catch (e: Exception) {
            e.printStackTrace()
            infoText = e.toString()
            infoText
        }
    }
}