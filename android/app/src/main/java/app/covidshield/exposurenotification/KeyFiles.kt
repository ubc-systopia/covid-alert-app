package app.covidshield.exposurenotification

import android.content.Context
import app.covidshield.BuildConfig
import app.covidshield.module.CovidShieldModule
import app.covidshield.shared.DateFns
import app.covidshield.storage.StorageDirectory
import app.covidshield.storage.StorageService
import app.covidshield.utils.SingletonHolder
import com.facebook.react.bridge.ReactApplicationContext
import java.lang.Math.max
import java.security.Key
import javax.crypto.Mac
import javax.crypto.spec.SecretKeySpec
import kotlin.math.floor

interface KeyFilesService {

    companion object : SingletonHolder<KeyFilesService, Context>(::DefaultKeyFilesService)

    fun download(period: Int)
    fun retrieveDiagnosisKeys(period: Int)
    fun getPeriodsSinceLastFetch(lastCheckedPeriod: Int = 0): Array<Int>

}

class DefaultKeyFilesService constructor(context: Context) : KeyFilesService {

    val covidShieldModule by lazy {
        CovidShieldModule(ReactApplicationContext(context))
    }

    val lastCheckedPeriod by lazy {
        StorageService.getInstance(context).retrieve(StorageDirectory)
    }

    override fun download(period: Int) {
        val periodsSinceLastFetch: Int = this.getPeriodsSinceLastFetch(lastCheckedPeriod);
        retrieveDiagnosisKeys(period)

    }

    override fun retrieveDiagnosisKeys(period: Int) {
        //Creating a Mac object
        val key: String = BuildConfig.HMAC_KEY
        val desKey: Key = SecretKeySpec(key.toByteArray(), "DES")
        val mac: Mac = Mac.getInstance("HmacSHA256")
        mac.init(desKey)
        val periodStr = if (period > 0) period.toString() else LAST_14_DAYS_PERIOD;
        val message = "${BuildConfig.MCC_CODE}:${periodStr}:${floor((DateFns.getCurrentDate() / 1000 / 3600).toDouble())}"
        val macResult = mac.doFinal(message.toByteArray())

        val url = "${BuildConfig.RETRIEVE_URL}/retrieve/${BuildConfig.MCC_CODE}/${periodStr}/${macResult}"
        covidShieldModule.downloadDiagnosisKeysFile(url)
    }

    override fun getPeriodsSinceLastFetch(lastCheckedPeriod: Int): Array<Int> {
        val today = DateFns.getCurrentDate()
        val currentPeriod = DateFns.periodSinceEpoch(today, HOURS_PER_PERIOD).toInt()
        if (lastCheckedPeriod == 0) {
            return arrayOf(0, currentPeriod)
        }
        val targetLastCheckedPeriod = max(lastCheckedPeriod - 1, currentPeriod - EXPOSURE_NOTIFICATION_CYCLE);
        var runningPeriod = currentPeriod
        val periodsToFetch = mutableListOf<Int>()
        while (runningPeriod > targetLastCheckedPeriod) {
            periodsToFetch.add(runningPeriod);
            runningPeriod -= 1;
        }
        return periodsToFetch.toTypedArray()
    }

    companion object {
        const val LAST_14_DAYS_PERIOD = "00000"
        const val HOURS_PER_PERIOD = 24
        const val EXPOSURE_NOTIFICATION_CYCLE = 14
    }
}