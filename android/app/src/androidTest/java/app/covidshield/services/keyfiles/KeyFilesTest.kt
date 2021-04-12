package app.covidshield.services.keyfiles

import android.content.Context
import androidx.test.platform.app.InstrumentationRegistry
import app.covidshield.exposurenotification.DefaultKeyFilesService.Companion.HOURS_PER_PERIOD
import app.covidshield.exposurenotification.KeyFilesService
import app.covidshield.shared.DateFns
import app.covidshield.shared.DateFns.Companion.periodSinceEpoch
import com.google.common.truth.Truth
import org.junit.Before
import org.junit.Test

class KeyFilesTest {

    lateinit var instrumentationContext: Context

    @Before
    fun setup() {
        instrumentationContext = InstrumentationRegistry.getInstrumentation().context
    }

    @Test
    fun getPeriodsSinceLastFetch_ReturnsNone() {
        val keyFileService = KeyFilesService.getInstance(instrumentationContext)
        Truth.assertThat(keyFileService.getPeriodsSinceLastFetch(0)).isEqualTo(arrayOf<Int>())
    }

}