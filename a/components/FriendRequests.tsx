import React, { useState } from 'react';
import { View, Text, FlatList, Image, TouchableOpacity, Alert } from 'react-native';

interface RequestUser {
  id: string;
  name: string;
  image: string;
  town: string;
}

interface FriendRequestsProps {
  receivedRequests: RequestUser[];
  sentRequests: RequestUser[];
  onAcceptRequest: (id: string) => void;
  onDeclineRequest: (id: string) => void;
  onCancelRequest: (id: string) => void;
  isAdmin?: boolean;
  isVip?: boolean;
  setShowPaywall?: (show: boolean) => void;
}

export const FriendRequests = ({ 
  receivedRequests, 
  sentRequests, 
  onAcceptRequest, 
  onDeclineRequest, 
  onCancelRequest,
  isAdmin,
  isVip,
  setShowPaywall
}: FriendRequestsProps) => {
  const [activeTab, setActiveTab] = useState<'received' | 'sent'>('received');

  // 🚨 THE VIP PAYWALL LOCK 🚨
  if (!isAdmin && !isVip) {
    return (
      <View className="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 mb-4 items-center justify-center">
        <Text className="text-[50px] mb-3">🔔</Text>
        <Text className="text-xl font-black text-gray-900 mb-2 text-center">Hidden Requests</Text>
        <Text className="text-sm text-gray-500 text-center mb-5 leading-5">
          Someone might be waiting to connect with you! Upgrade to VIP to see your pending friend requests.
        </Text>
        <TouchableOpacity 
          onPress={() => setShowPaywall && setShowPaywall(true)}
          className="bg-[#F43F5E] py-3 px-8 rounded-[30px] shadow-sm"
        >
          <Text className="text-white font-black tracking-widest uppercase">Unlock VIP</Text>
        </TouchableOpacity>
      </View>
    );
  }

  // 👇 IF THEY ARE ADMIN OR VIP, SHOW THE REQUESTS MANAGER 👇

  const handleAccept = (id: string, name: string) => {
    onAcceptRequest(id);
    Alert.alert("Added!", `You and ${name} are now friends.`);
  };

  const handleDecline = (id: string, name: string) => {
    Alert.alert("Decline Request", `Are you sure you want to decline ${name}?`, [
      { text: "Cancel", style: "cancel" },
      { text: "Decline", style: "destructive", onPress: () => onDeclineRequest(id) }
    ]);
  };

  const handleCancel = (id: string, name: string) => {
    Alert.alert("Cancel Request", `Withdraw your friend request to ${name}?`, [
      { text: "No", style: "cancel" },
      { text: "Withdraw", style: "destructive", onPress: () => onCancelRequest(id) }
    ]);
  };

  const currentData = activeTab === 'received' ? receivedRequests : sentRequests;

  return (
    <View className="bg-white rounded-2xl shadow-sm border border-gray-100 p-4 mb-4">
      <Text className="text-xl font-black text-gray-800 mb-3">🔔 Friend Requests</Text>
      
      {/* TABS */}
      <View className="flex-row bg-gray-100 rounded-lg p-1 mb-4">
        <TouchableOpacity 
          onPress={() => setActiveTab('received')}
          className={`flex-1 py-2 items-center rounded-md ${activeTab === 'received' ? 'bg-white shadow-sm' : ''}`}
        >
          <Text className={`font-bold ${activeTab === 'received' ? 'text-green-600' : 'text-gray-500'}`}>
            Received ({receivedRequests.length})
          </Text>
        </TouchableOpacity>
        <TouchableOpacity 
          onPress={() => setActiveTab('sent')}
          className={`flex-1 py-2 items-center rounded-md ${activeTab === 'sent' ? 'bg-white shadow-sm' : ''}`}
        >
          <Text className={`font-bold ${activeTab === 'sent' ? 'text-green-600' : 'text-gray-500'}`}>
            Sent ({sentRequests.length})
          </Text>
        </TouchableOpacity>
      </View>

      {/* LIST */}
      <FlatList 
        data={currentData}
        keyExtractor={(item) => item.id}
        scrollEnabled={false}
        ListEmptyComponent={
          <Text className="text-gray-400 text-center py-6 font-bold">
            {activeTab === 'received' ? "No pending requests." : "You haven't sent any requests."}
          </Text>
        }
        renderItem={({ item }) => (
          <View className="flex-row items-center bg-gray-50 p-3 rounded-xl mb-2 border border-gray-100">
            <Image source={{ uri: item.image }} className="w-12 h-12 rounded-full border border-gray-200 bg-gray-200 mr-3" />
            
            <View className="flex-1">
              <Text className="font-black text-gray-800 text-[15px]">{item.name}</Text>
              <Text className="text-gray-500 text-[12px]">{item.town}</Text>
            </View>

            {/* BUTTONS BASED ON TAB */}
            {activeTab === 'received' ? (
              <View className="flex-row">
                <TouchableOpacity 
                  onPress={() => handleDecline(item.id, item.name)}
                  className="bg-red-100 w-10 h-10 rounded-full items-center justify-center mr-2"
                >
                  <Text className="text-[18px]">❌</Text>
                </TouchableOpacity>
                <TouchableOpacity 
                  onPress={() => handleAccept(item.id, item.name)}
                  className="bg-green-100 w-10 h-10 rounded-full items-center justify-center"
                >
                  <Text className="text-[18px]">✅</Text>
                </TouchableOpacity>
              </View>
            ) : (
              <TouchableOpacity 
                onPress={() => handleCancel(item.id, item.name)}
                className="bg-gray-200 px-4 py-2 rounded-full"
              >
                <Text className="font-bold text-gray-600 text-xs">Cancel</Text>
              </TouchableOpacity>
            )}
          </View>
        )}
      />
    </View>
  );
};