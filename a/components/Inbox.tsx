import React from 'react';
import { View, Text, FlatList, Image, TouchableOpacity } from 'react-native';

export const Inbox = ({ messages, setMessages, profiles, setChatUser, setTab }: any) => {
  // Get all user IDs that have an active conversation
  const conversationUserIds = Object.keys(messages).filter(id => messages[id].length > 0);

  // Delete option to remove the conversation completely
  const deleteConversation = (userId: string) => {
    const updatedMessages = { ...messages };
    delete updatedMessages[userId];
    setMessages(updatedMessages);
  };

  return (
    <View className="flex-1 bg-white">
      {/* HEADER WITH RETURN BUTTON */}
      <View className="p-5 border-b border-gray-200 bg-gray-50 flex-row items-center justify-between">
        <View>
          <Text className="text-[28px] font-black text-gray-900">Inbox</Text>
          <Text className="text-[14px] text-gray-500 font-bold mt-1">Your private messages</Text>
        </View>
        <TouchableOpacity 
          onPress={() => setTab('discover')} 
          className="px-4 py-2 bg-gray-200 rounded-full"
        >
          <Text className="text-gray-800 font-black text-[14px]">← Back</Text>
        </TouchableOpacity>
      </View>

      {conversationUserIds.length === 0 ? (
        <View className="flex-1 justify-center items-center p-8">
          <Text className="text-[50px] mb-4">📬</Text>
          <Text className="text-[18px] font-black text-gray-800 text-center">No messages yet</Text>
          <Text className="text-[14px] text-gray-500 font-bold text-center mt-2">
            When someone sends you a private message, it will appear here.
          </Text>
        </View>
      ) : (
        <FlatList
          data={conversationUserIds}
          keyExtractor={(item) => item}
          contentContainerStyle={{ paddingBottom: 20 }}
          renderItem={({ item: userId }) => {
            const userProfile = profiles.find((p: any) => p.id === userId);
            if (!userProfile) return null;

            const userMessages = messages[userId];
            const lastMessage = userMessages[userMessages.length - 1];

            return (
              <TouchableOpacity 
                className="flex-row items-center p-4 border-b border-gray-100 bg-white"
                onPress={() => setChatUser(userProfile)}
              >
                <Image 
                  source={{ uri: userProfile.image }} 
                  className="w-[60px] h-[60px] rounded-full border-2 border-gray-200"
                />
                <View className="flex-1 ml-4 justify-center">
                  <Text className="text-[18px] font-black text-gray-900">{userProfile.name}, {userProfile.age}</Text>
                  <Text className="text-[14px] text-gray-500 font-bold mt-1" numberOfLines={1}>
                    {lastMessage.sender === 'me' ? 'You: ' : ''}{lastMessage.text}
                  </Text>
                </View>
                
                <TouchableOpacity 
                  className="w-[45px] h-[45px] bg-red-100 rounded-full justify-center items-center ml-2"
                  onPress={() => deleteConversation(userId)}
                >
                  <Text className="text-[20px]">🗑️</Text>
                </TouchableOpacity>
              </TouchableOpacity>
            );
          }}
        />
      )}
    </View>
  );
};