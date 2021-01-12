import {StyleSheet, Platform} from 'react-native';

export default StyleSheet.create({
  roundedBox1: {
    marginTop: Platform.OS === 'ios' ? 5 : 20,
    backgroundColor: 'white',
    borderRadius: 10,
    zIndex: -1,
  },
  roundedBox2: {
    borderRadius: 10,
    backgroundColor: 'white',
  },
  overlayContent: {
    marginTop: -26,
  },
  overlayCollapseButton: {
    height: 48,
    width: '100%',
    alignItems: 'center',
    justifyContent: 'flex-start',
    marginBottom: -10,
  },
  flex: {
    flex: 1,
  },
  primaryIcon: {marginLeft: -40, marginBottom: 30},
  scrollContainerWithAnimation: {
    marginTop: -100,
  },
  scrollView: {
    height: '100%',
  },
  scrollContainer: {
    maxWidth: 600,
    alignItems: 'flex-start',
  },
});
