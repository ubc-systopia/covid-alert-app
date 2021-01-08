import React, {useCallback, useState} from 'react';
import { TextInputMask } from 'react-native-masked-text';

import {Box} from './Box';
import {TextInput} from './TextInput';

export interface CodeInputProps {
  value: string;
  onChange: (value: string) => void;
  accessibilityLabel: string;
}

export const CodeInput = ({value, onChange, accessibilityLabel}: CodeInputProps) => {
  const onChangeTrimmed = useCallback(text => onChange(text.trim()), [onChange]);
  const [isFocus, setIsFocus] = useState(false);
  const onFocus = useCallback(() => setIsFocus(true), []);
  const onBlur = useCallback(() => setIsFocus(false), []);
  const [text, setText] = useState('');

//   <TextInput
//   color="bodyText"
//   value={value}
//   onChangeText={onChangeTrimmed}
//   onFocus={onFocus}
//   onBlur={onBlur}
//   autoCorrect={false}
//   autoCompleteType="off"
//   returnKeyType="done"
//   accessibilityLabel={accessibilityLabel}
//   padding="s"
//   maxLength={12}
//   fontSize={26}
//   borderWidth={0}
//   autoCapitalize="characters"
//   fontFamily="Menlo"
//   letterSpacing={5}
//   testID="textInput"
// />
  return (
    <>
      <Box
        marginHorizontal="none"
        borderRadius={9}
        borderWidth={4}
        borderColor={isFocus ? 'focus' : 'overlayBackground'}
      >
        <Box
          flex={1}
          paddingHorizontal="xs"
          borderWidth={2}
          borderColor={isFocus ? 'overlayBodyText' : 'gray2'}
          borderRadius={5}
        >
          <TextInputMask
            type="custom"
            options={{mask: 'SSS SSS SSSS'}}
            fontSize={26}
            autoCorrect={false}
            autoCompleteType="off"
            autoCapitalize="characters"
            fontFamily="Menlo"
            borderWidth={0}
            returnKeyType="done"
            letterSpacing={5}
            maxLength={12}
            // padding="s"
            value={text}
            onChangeText={text => {
              setText(text);
            }}
          />
        </Box>
      </Box>
    </>
  );
};
