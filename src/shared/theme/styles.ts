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
});
