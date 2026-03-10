import React from 'react';
import { KeyboardAvoidingView, Platform, Text, FlatList, View, TextInput, TouchableOpacity, Alert } from 'react-native';

export const Lobby = ({ 
  lobbyMessages, 
  lobbyInput, 
  setLobbyInput, 
  sendLobbyMessage,
  isAdmin,               // 🚀 ADDED: To bypass limits
  isVip,                 // 🚀 ADDED: To bypass limits
  setShowPaywall,        // 🚀 ADDED: To open subscription screen
  totalFreeMessages,     // 🚀 ADDED: Shared global counter
  setTotalFreeMessages   // 🚀 ADDED: Shared global counter updater
}: any) => {

  const handleSendMessage = () => {
    // 1. CHECK THE SHARED LIMIT FIRST
    if (!isAdmin && !isVip && totalFreeMessages >= 4) {
      Alert.alert(
        "Out of Free Messages! 🛑", 
        "You have used your 4 free messages across the app. Subscribe to VIP to send unlimited messages!",
        [
          { text: "Cancel", style: "cancel" },
          { text: "Unlock VIP", onPress: () => setShowPaywall && setShowPaywall(true) }
        ]
      );
      return; // Stop the function here so the message doesn't send
    }

    // 2. SEND THE MESSAGE IF ALLOWED
    if (lobbyInput.trim()) {
      sendLobbyMessage(); // Calls the original send function passed from parent
      
      // 3. INCREASE THE SHARED COUNT FOR FREE USERS
      if (!isAdmin && !isVip) {
        setTotalFreeMessages((prev: number) => prev + 1);
      }
    }
  };

  // Dynamic placeholder showing exactly how many total messages are left
  const placeholderText = (!isAdmin && !isVip) 
    ? `Say something... (${Math.max(0, 4 - totalFreeMessages)} left)` 
    : "Say something...";

  return (
    <KeyboardAvoidingView behavior={Platform.OS === 'ios' ? 'padding' : undefined} className="flex-1">
      <Text className="text-[24px] font-bold p-[15px] text-[#333]">Global Lobby Chat</Text>
      
      <FlatList 
        data={lobbyMessages} 
        keyExtractor={(item, index) => item.id ? item.id.toString() : index.toString()}
        renderItem={({item}) => (
          <View className="p-[15px] border-b border-[#F5F5F5]">
            <View className="flex-row justify-between items-center">
              <Text className="text-[#4CAF50] font-bold text-[14px]">{item.user}</Text>
              <Text className="text-[#AAA] text-[10px]">{item.time}</Text>
            </View>
            <Text className="mt-1 text-[#444] text-[15px]">{item.text}</Text>
          </View>
        )}
        contentContainerStyle={{paddingBottom: 20}}
        inverted={false}
      />

      <View className="flex-row p-[15px] mb-[80px] border-t border-[#EEE]">
        <TextInput 
          className="flex-1 h-[45px] bg-[#F5F5F5] rounded-[20px] px-[15px] text-black" 
          placeholder={placeholderText} 
          placeholderTextColor="#999"
          value={lobbyInput} 
          onChangeText={setLobbyInput} 
        />
        <TouchableOpacity onPress={handleSendMessage} className="ml-2.5 bg-[#4CAF50] px-[20px] rounded-[20px] justify-center">
          <Text className="text-white font-bold">SEND</Text>
        </TouchableOpacity>
      </View>
      
    </KeyboardAvoidingView>
  );
};