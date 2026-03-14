import React, { useState } from 'react';
import { View, StyleSheet, KeyboardAvoidingView, Platform, Alert, TouchableOpacity, Image } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
// 🚀 IMPORTING PROFESSIONAL UI COMPONENTS
import { TextInput, Button, Text, Provider as PaperProvider, MD3LightTheme } from 'react-native-paper';
import { Feather } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient'; 

// =========================================================================
// 🚨 THE MASTER URL SWITCH 🚨
// =========================================================================
const API_URL = "http://10.0.2.2:3001";
// =========================================================================

// 🚀 NOW USING LOCAL FILES WITH YOUR CUSTOM "1" NAMES 🚀
const ICONS = {
  mail: require('../assets/mail1.png'),
  lock: require('../assets/lock1.png'),
  eye: require('../assets/eye1.png'),
  eyeOff: require('../assets/eyeoff1.png')
};

// Premium Rose Theme
const theme = {
  ...MD3LightTheme,
  colors: {
    ...MD3LightTheme.colors,
    primary: '#F43F5E', 
    background: '#ffffff',
  },
};

export const LoginScreen = ({ navigation }: any) => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);

  const handleLogin = async () => {
    if (!email || !password) {
      return Alert.alert("Error", "Please enter your email and password.");
    }
    setIsLoading(true);
    try {
      const response = await fetch(`${API_URL}/api/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: email.toLowerCase(), password })
      });
      const data = await response.json();
      if (!response.ok) {
        Alert.alert("Login Failed", data.error || "Invalid credentials.");
      } else {
        navigation.replace('Main', { user: data.user });
      }
    } catch (error) {
      Alert.alert("Network Error", "Could not connect to the server.");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <PaperProvider theme={theme}>
      <SafeAreaView style={styles.container}>
        <KeyboardAvoidingView behavior={Platform.OS === 'ios' ? 'padding' : 'height'} style={styles.flex1}>
          
          {/* TOP NAV */}
          <TouchableOpacity onPress={() => navigation.goBack()} style={styles.backButton}>
            <Feather name="arrow-left" size={28} color="#000" />
          </TouchableOpacity>

          <View style={styles.content}>
            {/* HEADER */}
            <View style={styles.header}>
              <Text variant="displaySmall" style={styles.title}>Welcome back.</Text>
              <Text variant="titleMedium" style={styles.subtitle}>Sign in to continue your journey.</Text>
            </View>

            {/* REAL MATERIAL DESIGN INPUTS USING IMAGES INSTEAD OF FONTS */}
            <View style={styles.form}>
              <TextInput
                mode="outlined"
                label="Email Address"
                value={email}
                onChangeText={setEmail}
                autoCapitalize="none"
                keyboardType="email-address"
                style={styles.input}
                outlineStyle={styles.inputOutline}
                // 🚀 INSERTED IMAGE FOR EMAIL 🚀
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
                // 🚀 INSERTED IMAGE FOR LOCK 🚀
                left={<TextInput.Icon icon={() => <Image source={ICONS.lock} style={{ width: 22, height: 22 }} />} />}
                // 🚀 INSERTED IMAGE FOR EYE (VISIBLE/HIDE) 🚀
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

              <TouchableOpacity style={styles.forgotPassword}>
                <Text style={styles.forgotText}>Forgot Password?</Text>
              </TouchableOpacity>
            </View>

            {/* PROFESSIONAL BUTTON */}
            <LinearGradient
              colors={['#F43F5E', '#FF7A59', 'blue']} 
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 0 }}
              style={{
                padding: 2, 
                borderRadius: 30, 
                marginBottom: 12,
              }}
            >
              <Button 
                onPress={handleLogin} 
                loading={isLoading}
                disabled={isLoading}
                mode="contained" 
                buttonColor="#1F2937" 
                textColor="#FFFFFF"   
                contentStyle={styles.buttonContent}
                style={{ borderRadius: 30 }} 
                labelStyle={styles.buttonLabel}
              >
                Sign In
              </Button>
            </LinearGradient>

            <View style={styles.footer}>
              <Text style={styles.footerText}>Don't have an account? </Text>
              <TouchableOpacity onPress={() => navigation.navigate('SignUp')}>
                <Text style={styles.linkText}>Sign Up</Text>
              </TouchableOpacity>
            </View>
          </View>
        </KeyboardAvoidingView>
      </SafeAreaView>
    </PaperProvider>
  );
};

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: 'pink' },
  flex1: { flex: 1 },
  backButton: { padding: 20, paddingTop: 10 },
  content: { flex: 1, paddingHorizontal: 24, justifyContent: 'center', paddingBottom: 40 },
  header: { marginBottom: 40 },
  title: { fontWeight: '900', color: '#000', marginBottom: 8 },
  subtitle: { color: '#6B7280', fontWeight: 'bold' },
  form: { marginBottom: 32 },
  input: { marginBottom: 16, backgroundColor: '#ffffff' },
  inputOutline: { borderRadius: 12, borderColor: 'black', borderWidth: 1},
  forgotPassword: { alignSelf: 'flex-end', marginTop: -4 },
  forgotText: { color: '#F43F5E', fontWeight: 'bold' },
  button: { borderRadius: 50, shadowColor: '#F43F5E', shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.2, shadowRadius: 8, elevation: 4 },
  buttonContent: { height: 56 },
  buttonLabel: { fontSize: 18, fontWeight: '900', letterSpacing: 0.5 },
  footer: { flexDirection: 'row', justifyContent: 'center', marginTop: 32 },
  footerText: { color: '#6B7280', fontWeight: 'bold', fontSize: 15 },
  linkText: { color: '#F43F5E', fontWeight: '900', fontSize: 15 }
});