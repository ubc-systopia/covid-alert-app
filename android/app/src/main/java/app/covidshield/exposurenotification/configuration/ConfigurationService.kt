package app.covidshield.exposurenotification.configuration

import android.content.Context
import app.covidshield.models.Configuration
import app.covidshield.utils.SingletonHolder
import com.google.gson.Gson
import okhttp3.CacheControl
import okhttp3.OkHttpClient
import okhttp3.Request
import java.io.IOException

interface ConfigurationService {

    companion object : SingletonHolder<ConfigurationService, Context>(::DefaultConfigurationService)

    fun retrieve(url: String): Configuration
    fun download(url: String): Configuration
    fun validate()
}

private class DefaultConfigurationService constructor(context: Context) : ConfigurationService {

    private val okHttpClient by lazy { OkHttpClient() }
    private val gson by lazy { Gson() }

    override fun retrieve(url: String): Configuration {
        // TODO: check for cached version of configuration
        val downloadedConfiguration = download(url)
        return downloadedConfiguration
    }

    override fun download(url: String): Configuration{
        val request = Request.Builder()
                .cacheControl(CacheControl.Builder().noStore().build())
                .url(url).build()
        okHttpClient.newCall(request).execute().use { response ->
            if (!response.isSuccessful) {
                throw IOException("Downloading configuration: Unexpected code ${response.code()}")
            }
            val bytes = response.body()?.bytes() ?: throw IOException()
            val json = gson.fromJson(String(bytes), Configuration::class.java)
            return json
        }
    }

    override fun validate(){
        // TODO: validate configuration against a JSON schema
    }

}