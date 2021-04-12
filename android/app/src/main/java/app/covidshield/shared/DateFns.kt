package app.covidshield.shared

import kotlin.math.floor

class DateFns {
    companion object {
        fun getCurrentDate(): Long{
            return System.currentTimeMillis()
        }

        fun periodSinceEpoch(date: Long, hoursPerPeriod: Int): Double {
            return floor((date / (1000 * 3600 * hoursPerPeriod)).toDouble());
        }
    }
}