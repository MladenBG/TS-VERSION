import React from 'react';
import { KeyboardAvoidingView, Platform, Text, FlatList, View, TextInput, TouchableOpacity } from 'react-native';

export const Lobby = ({ lobbyMessages, lobbyInput, setLobbyInput, sendLobbyMessage }: any) => {
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
          placeholder="Say something..." 
          placeholderTextColor="#999"
          value={lobbyInput} 
          onChangeText={setLobbyInput} 
        />
        <TouchableOpacity onPress={sendLobbyMessage} className="ml-2.5 bg-[#4CAF50] px-[20px] rounded-[20px] justify-center">
          <Text className="text-white font-bold">SEND</Text>
        </TouchableOpacity>
      </View>
      
    </KeyboardAvoidingView>
  );
};