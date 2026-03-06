import React, { useState } from 'react';
import { Modal, ScrollView, TouchableOpacity, View, Text, Alert, Platform, ActivityIndicator } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import Purchases from 'react-native-purchases';

export const Subscription = ({ showPaywall, setShowPaywall, handlePayment }: any) => {
  const [isProcessing, setIsProcessing] = useState(false);

  // --- GOOGLE PAY / REVENUECAT LOGIC ---
  const triggerGooglePay = async (planIdentifier: string) => {
    setIsProcessing(true);
    try {
      // This line literally opens the Google Play payment sheet at the bottom of the Android phone
      // Replace these with the exact IDs you make in Google Play Console
      let productId = '';
      if (planIdentifier === 'Daily') {
        productId = 'dateroot_daily';
      } else if (planIdentifier === 'Weekly') {
        productId = 'dateroot_weekly';
      } else {
        productId = 'dateroot_monthly';
      }
      
      // UNCOMMENT THIS LINE WHEN YOUR GOOGLE PLAY ACCOUNT IS LINKED:
      // const { customerInfo } = await Purchases.purchaseProduct(productId);
      
      // For now, we simulate a successful Google Pay transaction and tell App.tsx to unlock VIP
      handlePayment(planIdentifier);
      
    } catch (e: any) {
      if (!e.userCancelled) {
        Alert.alert("Google Pay Error", e.message);
      }
    } finally {
      setIsProcessing(false);
    }
  };

  const restoreGooglePurchases = async () => {
    setIsProcessing(true);
    try {
      // This checks Google Play to see if they already bought VIP on an old phone
      // const purchaserInfo = await Purchases.restorePurchases();
      
      Alert.alert("Google Play", "Purchases successfully restored.");
      setShowPaywall(false);
    } catch (e: any) {
      Alert.alert("Restore Error", e.message);
    } finally {
      setIsProcessing(false);
    }
  };

  return (
    <Modal visible={showPaywall} animationType="slide">
      <SafeAreaView className="flex-1 bg-white">
        <ScrollView contentContainerStyle={{ padding: 20, alignItems: 'center' }}>
          
          <TouchableOpacity onPress={() => setShowPaywall(false)} className="self-end p-[10px]">
            <Text className="text-[30px] text-black">✕</Text>
          </TouchableOpacity>
          
          <Text className="text-[32px] font-[900] mt-5 mb-2.5 text-black">
            Dateroot <Text className="text-[#4CAF50]">PRO</Text>
          </Text>
          <Text className="text-center mb-[30px] text-[#666]">
            Unlock Swipe Mode, Radar, and Unlimited Messaging
          </Text>

          {/* DAILY PLAN (NEW) */}
          <View className="w-full p-[25px] rounded-[20px] bg-[#F9F9F9] my-2.5">
            <Text className="text-[20px] font-bold text-black">24 Hour Pass</Text>
            <Text className="text-[28px] font-[900] my-2.5 text-black">$4.00</Text>
            <Text className="text-[12px] text-[#999]">Valid for 1 Day</Text>
            <TouchableOpacity 
              className="bg-[#4CAF50] p-[15px] rounded-[12px] items-center mt-[15px]" 
              onPress={() => triggerGooglePay('Daily')}
              disabled={isProcessing}
            >
              <Text className="text-white font-bold">
                {isProcessing ? "Connecting to Google Pay..." : "Pay $4 with Google Play"}
              </Text>
            </TouchableOpacity>
          </View>
          
          {/* WEEKLY PLAN */}
          <View className="w-full p-[25px] rounded-[20px] bg-[#F9F9F9] my-2.5">
            <Text className="text-[20px] font-bold text-black">Weekly Access</Text>
            <Text className="text-[28px] font-[900] my-2.5 text-black">$7.00</Text>
            <Text className="text-[12px] text-[#999]">Renews every 7 days</Text>
            <TouchableOpacity 
              className="bg-[#4CAF50] p-[15px] rounded-[12px] items-center mt-[15px]" 
              onPress={() => triggerGooglePay('Weekly')}
              disabled={isProcessing}
            >
              <Text className="text-white font-bold">
                {isProcessing ? "Connecting to Google Pay..." : "Pay $7 with Google Play"}
              </Text>
            </TouchableOpacity>
          </View>

          {/* MONTHLY PLAN */}
          <View className="w-full p-[25px] rounded-[20px] bg-[#F9F9F9] my-2.5 border-2 border-[#4CAF50]">
            <View className="absolute -top-2.5 right-5 bg-[#4CAF50] p-1.5 px-2.5 rounded-[10px]">
              <Text className="text-white text-[10px] font-bold">BEST VALUE</Text>
            </View>
            <Text className="text-[20px] font-bold text-black">Monthly Gold</Text>
            <Text className="text-[28px] font-[900] my-2.5 text-black">$15.00</Text>
            <Text className="text-[12px] text-[#999]">Renews every month</Text>
            <TouchableOpacity 
              className="bg-black p-[15px] rounded-[12px] items-center mt-[15px]" 
              onPress={() => triggerGooglePay('Monthly')}
              disabled={isProcessing}
            >
              <Text className="text-white font-bold">
                {isProcessing ? "Connecting to Google Pay..." : "Pay $15 with Google Play"}
              </Text>
            </TouchableOpacity>
          </View>
          
          {/* RESTORE PURCHASES */}
          <TouchableOpacity onPress={restoreGooglePurchases} disabled={isProcessing}>
            <Text className="text-[#999] mt-5 mb-10">Restore Google Play Purchases</Text>
          </TouchableOpacity>

        </ScrollView>
      </SafeAreaView>
    </Modal>
  );
};