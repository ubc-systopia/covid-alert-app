import React, {useCallback} from 'react';
import {useI18n} from 'locale';
import {ToolbarWithClose} from 'components';
import {useNavigation, useRoute, RouteProp} from '@react-navigation/native';
import {SafeAreaView} from 'react-native-safe-area-context';
import {ScrollView} from 'react-native-gesture-handler';
import {StyleSheet} from 'react-native';
import {ExposureType} from 'shared/qr';
import {OutbreakExposedView} from 'screens/home/views/OutbreakExposedView';
import {ProximityExposureView} from 'screens/home/views/ProximityExposureView';

import {MainStackParamList} from '../../navigation/MainNavigator';

type RecentExposureScreenProps = RouteProp<MainStackParamList, 'RecentExposureScreen'>;

const ExposureView = () => {
  const route = useRoute<RecentExposureScreenProps>();
  if (route.params.exposureType === ExposureType.Outbreak) {
    return <OutbreakExposedView timestamp={route.params.timestamp} />;
  }
  if (route.params.exposureType === ExposureType.Proximity) {
    return <ProximityExposureView timestamp={route.params.timestamp} />;
  }
  return null;
};

export const RecentExposureScreen = () => {
  const i18n = useI18n();

  const navigation = useNavigation();
  const close = useCallback(() => navigation.navigate('Menu'), [navigation]);
  return (
    <SafeAreaView style={styles.flex}>
      <ToolbarWithClose closeText={i18n.translate('DataUpload.Close')} showBackButton onClose={close} />
      <ScrollView style={styles.flex}>
        <ExposureView />
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  flex: {
    flex: 1,
  },
});
