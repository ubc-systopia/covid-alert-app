import {Platform} from 'react-native';
import Config from 'react-native-config';
import NetInfo from '@react-native-community/netinfo';

export const APP_ID = Platform.select({
  android: Config.APP_ID,
  ios: Config.APP_ID,
})!!;

export const APP_VERSION_CODE = parseInt(Config.APP_VERSION_CODE, 10);

export const APP_VERSION_NAME = Config.APP_VERSION_NAME;

export const SUBMIT_URL = Config.SUBMIT_URL;

export const RETRIEVE_URL = Config.RETRIEVE_URL;

export const NOTIFICATION_FEED_URL = Config.NOTIFICATION_FEED_URL;

export const HMAC_KEY = Config.HMAC_KEY;

export const MCC_CODE = parseInt(Config.MCC_CODE, 10) || 302;

export const TEST_MODE = Config.TEST_MODE === 'true' || false;

export const MOCK_SERVER = Config.MOCK_SERVER === 'true' || false;

export const REGION_JSON_URL = Config.REGION_JSON_URL;

export const EN_CONFIG_URL = Config.EN_CONFIG_URL;

export const EN_API_VERSION = Config.EN_API_VERSION;

export const LOGGLY_URL = Config.LOGGLY_URL || false;

export const LOG_LEVEL = Config.LOG_LEVEL || 'debug';

export const QR_HOST = Config.QR_HOST || '';

export const QR_CODE_PUBLIC_KEY = Config.QR_CODE_PUBLIC_KEY || '';

export const QR_ENABLED = Config.QR_ENABLED === 'true' || false;

export const METRICS_URL = Config.METRICS_URL || false;

export const METRICS_API_KEY = Config.METRICS_API_KEY;

/**
 * Set reachability check url to empty to prevent
 * unnecessary background network activity
 */
NetInfo.configure({
  reachabilityUrl: '',
});
