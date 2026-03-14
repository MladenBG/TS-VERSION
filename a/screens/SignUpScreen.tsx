import React, { useState } from 'react';
import { View, StyleSheet, KeyboardAvoidingView, Platform, Alert, TouchableOpacity, ScrollView, Image } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { LinearGradient } from 'expo-linear-gradient';
import { TextInput, Button, Text, SegmentedButtons, Provider as PaperProvider, MD3LightTheme, HelperText } from 'react-native-paper';
import { Feather } from '@expo/vector-icons';

const API_URL = "http://10.0.2.2:3001";

// 🚀 LOCAL FILES FROM YOUR ASSETS FOLDER 🚀
const ICONS = {
  account: require('../assets/account2.png'),
  mail: require('../assets/mail2.png'),
  lock: require('../assets/lock2.png'),
  shield: require('../assets/shield2.png'), 
  eye: require('../assets/eye2.png'),
  eyeOff: require('../assets/eyeoff2.png')
};

const theme = {
  ...MD3LightTheme,
  colors: {
    ...MD3LightTheme.colors,
    primary: '#F43F5E',
    background: '#ffffff',
    secondaryContainer: '#FFE4E6', 
  },
};

export const SignUpScreen = ({ navigation }: any) => {
  const [firstName, setFirstName] = useState('');
  const [lastName, setLastName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [gender, setGender] = useState('');
  const [is18, setIs18] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);

  // Live Password Validations
  const hasMinLength = (password || "").length >= 8;
  const hasUppercase = /[A-Z]/.test(password || "");
  const hasNumber = /\d/.test(password || "");
  const hasSpecial = /[!@#$%^&*(),.?":{}|<>]/.test(password || "");
  
  const isPasswordValid = hasMinLength && hasUppercase && hasNumber && hasSpecial;
  const doPasswordsMatch = password === confirmPassword && (password || "").length > 0;

  const handleSignUp = async () => {
    if (!firstName || !lastName || !email || !password || !confirmPassword || !gender) {
      return Alert.alert("Error", "Please fill all fields.");
    }

    const safeEmail = (email || "").toLowerCase().trim();

    if (!isPasswordValid) return Alert.alert("Error", "Please meet all password requirements.");
    if (!doPasswordsMatch) return Alert.alert("Error", "Passwords do not match.");
    if (!is18) return Alert.alert("Error", "You must be 18 or older.");

    setIsLoading(true);
    try {
      const fullName = `${firstName.trim()} ${lastName.trim()}`;

      // 🚀 FIXED: ADDED /api/ SO IT DOESN'T 404 CRASH 🚀
      const response = await fetch(`${API_URL}/api/auth/signup`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ 
          name: fullName, 
          email: safeEmail, 
          password, 
          gender 
        })
      });
      
      const data = await response.json();
      
      if (!response.ok) {
        Alert.alert("Signup Failed", data.error || "Something went wrong.");
      } else {
        navigation.replace('Main', { user: data.user });
      }
    } catch (error) {
      console.error("Signup Error:", error);
      Alert.alert("Network Error", "Could not connect to server. Is the backend running?");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <PaperProvider theme={theme}>
      <SafeAreaView style={styles.container}>
        <KeyboardAvoidingView behavior={Platform.OS === 'ios' ? 'padding' : 'height'} style={styles.flex1}>
          
          <View style={styles.navBar}>
            <TouchableOpacity onPress={() => navigation.goBack()}>
              <Feather name="arrow-left" size={28} color="#000" />
            </TouchableOpacity>
          </View>

          <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
            <View style={styles.header}>
              <Text variant="displaySmall" style={styles.title}>Create Account.</Text>
              <Text variant="titleMedium" style={styles.subtitle}>Join DateRoot to start connecting.</Text>
            </View>

            <View style={styles.form}>
              
              <TextInput
                mode="outlined"
                label="First Name"
                value={firstName}
                onChangeText={setFirstName}
                style={styles.input}
                outlineStyle={styles.inputOutline}
                left={<TextInput.Icon icon={() => <Image source={ICONS.account} style={{ width: 22, height: 22 }} />} />}
              />

              <TextInput
                mode="outlined"
                label="Last Name"
                value={lastName}
                onChangeText={setLastName}
                style={styles.input}
                outlineStyle={styles.inputOutline}
                left={<TextInput.Icon icon={() => <Image source={ICONS.account} style={{ width: 22, height: 22 }} />} />}
              />

              <TextInput
                mode="outlined"
                label="Email Address"
                value={email}
                onChangeText={setEmail}
                autoCapitalize="none"
                keyboardType="email-address"
                style={styles.input}
                outlineStyle={styles.inputOutline}
                left={<TextInput.Icon icon={() => <Image source={ICONS.mail} style={{ width: 22, height: 22 }} />} />}
              />
              
              <TextInput
                mode="outlined"
                label="Password"
                value={password}
                onChangeText={setPassword}
                secureTextEntry={!showPassword}
                style={styles.input}
                outlineStyle={styles.inputOutline}
                left={<TextInput.Icon icon={() => <Image source={ICONS.lock} style={{ width: 22, height: 22 }} />} />}
                right={
                  <TextInput.Icon 
                    icon={() => (
                      <Image 
                        source={showPassword ? ICONS.eyeOff : ICONS.eye} 
                        style={{ width: 22, height: 22 }} 
                      />
                    )} 
                    onPress={() => setShowPassword(!showPassword)} 
                  />
                }
              />
              
              <View style={styles.requirementsBox}>
                <Text style={[styles.reqText, hasMinLength ? styles.reqValid : styles.reqInvalid]}>• At least 8 characters</Text>
                <Text style={[styles.reqText, hasUppercase ? styles.reqValid : styles.reqInvalid]}>• One Uppercase letter</Text>
                <Text style={[styles.reqText, hasNumber ? styles.reqValid : styles.reqInvalid]}>• One Number</Text>
                <Text style={[styles.reqText, hasSpecial ? styles.reqValid : styles.reqInvalid]}>• One Special Symbol</Text>
              </View>
              
              <TextInput
                mode="outlined"
                label="Confirm Password"
                value={confirmPassword}
                onChangeText={setConfirmPassword}
                secureTextEntry={!showPassword}
                style={styles.input}
                outlineStyle={styles.inputOutline}
                left={<TextInput.Icon icon={() => <Image source={ICONS.shield} style={{ width: 22, height: 22 }} />} />}
              />
              <HelperText type={doPasswordsMatch ? "info" : "error"} visible={(confirmPassword || "").length > 0}>
                {doPasswordsMatch ? 'Passwords match' : 'Passwords do not match'}
              </HelperText>

              <Text variant="labelLarge" style={styles.sectionLabel}>I am a:</Text>
              <SegmentedButtons
                value={gender}
                onValueChange={setGender}
                buttons={[
                  { value: 'Male', label: 'Male' },
                  { value: 'Female', label: 'Female' },
                  { value: 'Other', label: 'Other' },
                ]}
                style={styles.segmentedBtn}
              />

              <TouchableOpacity 
                style={styles.customCheckboxContainer} 
                onPress={() => setIs18(!is18)}
                activeOpacity={0.7}
              >
                <View style={[styles.customBox, is18 && styles.customBoxChecked]}>
                  {is18 && <Feather name="check" size={16} color="white" />}
                </View>
                <Text style={styles.checkboxLabel}>I confirm that I am 18 years or older.</Text>
              </TouchableOpacity>

            </View>

            <LinearGradient
              colors={['#F43F5E', '#FF7A59', 'blue']}
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 0 }}
              style={{
                padding: 2,
                borderRadius: 30,
                marginTop: 10,
              }}
            >
              <Button 
                mode="contained" 
                onPress={handleSignUp} 
                loading={isLoading}
                disabled={isLoading || !isPasswordValid || !doPasswordsMatch || !is18}
                buttonColor="#1F2937" 
                textColor="#FFFFFF"
                style={{ borderRadius: 30 }}
                contentStyle={styles.buttonContent}
                labelStyle={styles.buttonLabel}
              >
                Create Account
              </Button>
            </LinearGradient>

            <View style={styles.footer}>
              <Text style={styles.footerText}>Already have an account? </Text>
              <TouchableOpacity onPress={() => navigation.navigate('Login')}>
                <Text style={styles.linkText}>Sign In</Text>
              </TouchableOpacity>
            </View>
          </ScrollView>
        </KeyboardAvoidingView>
      </SafeAreaView>
    </PaperProvider>
  );
};

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: 'pink' },
  flex1: { flex: 1 },
  navBar: { paddingHorizontal: 20, paddingTop: 10, paddingBottom: 10 },
  scrollContent: { paddingHorizontal: 24, paddingBottom: 40 },
  header: { marginBottom: 30, marginTop: 10 },
  title: { fontWeight: '900', color: '#000', marginBottom: 8 },
  subtitle: { color: '#6B7280', fontWeight: 'bold' },
  form: { marginBottom: 20 },
  input: { marginBottom: 12, backgroundColor: '#ffffff' },
  inputOutline: { borderRadius: 12, borderColor: 'black', borderWidth: 1},
  requirementsBox: { backgroundColor: 'grey', padding: 12, borderRadius: 12, marginBottom: 16, borderWidth: 3, borderColor: 'white'},
  reqText: { fontSize: 13, fontWeight: '600', marginBottom: 4 },
  reqValid: { color: '#10B981' },
  reqInvalid: { color: 'white' },
  sectionLabel: { fontWeight: '900', color: '#000', marginTop: 10, marginBottom: 10 },
  segmentedBtn: { marginBottom: 20 },
  
  customCheckboxContainer: { 
    flexDirection: 'row', 
    alignItems: 'center', 
    marginTop: 10,
    marginBottom: 10 
  },
  customBox: {
    width: 24,
    height: 24,
    borderWidth: 2,
    borderColor: 'black', 
    borderRadius: 6,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: 'transparent',
    marginRight: 10,
  },
  customBoxChecked: {
    backgroundColor: 'red', 
    borderColor: 'red',     
  },
  
  checkboxLabel: { fontSize: 15, fontWeight: '700', color: '#374151', textAlign: 'left' },
  button: { borderRadius: 50, marginTop: 10 },
  buttonContent: { height: 56 },
  buttonLabel: { fontSize: 18, fontWeight: '900', letterSpacing: 0.5 },
  footer: { flexDirection: 'row', justifyContent: 'center', marginTop: 32 },
  footerText: { color: '#6B7280', fontWeight: 'bold', fontSize: 15 },
  linkText: { color: '#F43F5E', fontWeight: '900', fontSize: 15 }
});