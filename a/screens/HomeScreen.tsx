import React from 'react';
import { View, Image, StyleSheet } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { LinearGradient } from 'expo-linear-gradient'; 
// (or import LinearGradient from 'react-native-linear-gradient';)

// 🚀 IMPORTING THE DOWNLOADED UI COMPONENTS 🚀
import { Button, Text, Provider as PaperProvider, MD3LightTheme } from 'react-native-paper';

// Setting up a modern, premium theme color for the downloaded components
const theme = {
  ...MD3LightTheme,
  colors: {
    ...MD3LightTheme.colors,
    primary: '#F43F5E', // Premium Rose Red
    outline: 'black', // Soft gray for outlines
  },
};

export const HomeScreen = ({ navigation }: any) => {
  return (
    <PaperProvider>
      <SafeAreaView style={styles.container}>
        
        {/* LOGO */}
        <View style={styles.logoContainer}>
          <Image 
            source={require('../assets/logo.png')} 
            style={styles.logo} 
            resizeMode="contain" 
          />
        </View>

        {/* TYPOGRAPHY COMPONENTS FROM UI LIBRARY */}
        <View style={styles.content}>
          <Text variant="displayMedium" style={styles.headline}>
            Meet your person.
          </Text>
          <Text variant="titleMedium" style={styles.subtitle}>
            The premium dating network. No noise, just genuine connections.
          </Text>
        </View>

        {/* 🚀 REAL PRE-BUILT BUTTON COMPONENTS 🚀 */}
        <View style={styles.buttonContainer}>
          
          {/* FIRST PRIMARY BUTTON (Rose Red) */}
          <Button 
            mode="contained" 
            onPress={() => navigation.navigate('SignUp')}
            buttonColor="#F43F5E" // 👈 Solid Rose Red background
            textColor="#FFFFFF"   // 👈 White text
            contentStyle={styles.buttonContent}
            style={styles.button}
            labelStyle={styles.buttonLabel}
          >
            Create Account
          </Button>

         {/* SECOND BUTTON WITH GRADIENT BORDER */}
<LinearGradient
  colors={['#F43F5E', '#FF7A59', 'blue']} // 👈 Your Pink-to-Red gradient colors!
  start={{ x: 0, y: 0 }}
  end={{ x: 1, y: 0 }}
  style={{
    padding: 2, // 👈 THIS IS YOUR BORDER THICKNESS
    borderRadius: 30, // Must be slightly bigger than the button's radius
    marginBottom: 12,

  }}
>
  <Button 
    mode="contained" 
    onPress={() => navigation.navigate('Login')}
    buttonColor="#1F2937" // 👈 The solid dark center
    textColor="#FFFFFF"   
    contentStyle={styles.buttonContent}
    style={{ borderRadius: 30 }} // 👈 Inner radius
    labelStyle={styles.buttonLabel}
  >
    Sign In
  </Button>
</LinearGradient>

        </View>
      </SafeAreaView>
    </PaperProvider>
  );
};

// Clean, standard styling to arrange the downloaded components
const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'pink',
    paddingHorizontal: 24,
    paddingBottom: 40,
  },
  logoContainer: {
    marginTop: 20,
    alignItems: 'flex-start',
  },
  logo: {
    width: 120,
    height: 40,
  },
  content: {
    flex: 1,
    justifyContent: 'center',
  },
  headline: {
    fontWeight: '900',
    color: '#000000',
    marginBottom: 16,
    lineHeight: 52,
  },
  subtitle: {
    color: '#6B7280',
    fontWeight: 'bold',
  },
  buttonContainer: {
    width: '100%',
  },
  button: {
    marginBottom: 16,
    borderRadius: 50, // Perfect pill shape
    color: 'black',
     borderWidth: 5, 
    borderColor: 'gradient-pink-red', // Put your color here
  },
  buttonContent: {
    height: 60, // Tall, modern button height
  },
  buttonLabel: {
    fontSize: 18,
    fontWeight: '900',
    letterSpacing: 0.5,
  },
  buttonLabelDark: {
    fontSize: 18,
    fontWeight: '900',
    letterSpacing: 0.5,
    color: 'white',

  }
});