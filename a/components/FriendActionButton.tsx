import React, { useState, useEffect } from 'react';
import { TouchableOpacity, Text, Alert, ActivityIndicator } from 'react-native';

// 🚀 FIXED: PORT CHANGED FROM 3000 TO 3001 TO MATCH SERVER 🚀
const API_URL = "http://10.0.2.2:3001";

export const FriendActionButton = ({ 
  selectedUser, 
  myId, 
  isAdmin, 
  isVip, 
  onRequirePaywall // 🚀 FIXED PROP NAME 
}: any) => {
  
  const [status, setStatus] = useState<'none' | 'pending' | 'friends'>('none');
  const [isLoading, setIsLoading] = useState(false);

  // 🚀 FIXED: CHECKS IF ALREADY FRIENDS ON LOAD 🚀
  useEffect(() => {
    if (selectedUser?.friends?.some((f: any) => f.id === myId || f.user_id === myId || f.friend_id === myId)) {
      setStatus('friends');
    } else {
      setStatus('none'); 
    }
  }, [selectedUser, myId]);

  const handlePress = async () => {
    // 1. VIP / Admin Check
    if (!isAdmin && !isVip) {
      if (onRequirePaywall) onRequirePaywall(); 
      return;
    }

    setIsLoading(true);

    try {
      if (status === 'none') {
        // 🚀 SEND FRIEND REQUEST
        await fetch(`${API_URL}/api/friends`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ user_id: myId, friend_id: selectedUser.id, action: 'request' })
        });
        setStatus('pending');
        Alert.alert("Request Sent", `You sent a friend request to ${selectedUser.name}!`);

      } else if (status === 'pending') {
        // 🚀 CANCEL FRIEND REQUEST
        await fetch(`${API_URL}/api/friends/cancel`, {
          method: 'POST', 
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ user_id: myId, friend_id: selectedUser.id })
        });
        setStatus('none');
        Alert.alert("Request Cancelled", `Friend request to ${selectedUser.name} has been withdrawn.`);

      } else if (status === 'friends') {
        // 🚀 UNFRIEND USER
        Alert.alert(
          "Unfriend",
          `Are you sure you want to remove ${selectedUser.name} from your friends?`,
          [
            { text: "Cancel", style: "cancel", onPress: () => setIsLoading(false) },
            { 
              text: "Unfriend", 
              style: "destructive", 
              onPress: async () => {
                await fetch(`${API_URL}/api/friends/remove`, {
                  method: 'POST', 
                  headers: { 'Content-Type': 'application/json' },
                  body: JSON.stringify({ user_id: myId, friend_id: selectedUser.id })
                });
                setStatus('none');
                setIsLoading(false);
              }
            }
          ]
        );
        return; 
      }
    } catch (error) {
      console.error("Friend action failed:", error);
      Alert.alert("Error", "Could not connect to the server.");
    }
    
    setIsLoading(false);
  };

  // 🚀 DYNAMIC STYLING BASED ON STATUS 🚀
  let bgClass = "bg-[#E8F5E9] border-[#4CAF50]";
  let textClass = "text-[#4CAF50]";
  let icon = "🤝";
  let label = "Add as Friend (VIP)";

  if (status === 'pending') {
    bgClass = "bg-yellow-50 border-yellow-400";
    textClass = "text-yellow-600";
    icon = "⏳";
    label = "Request Sent (Cancel)";
  } else if (status === 'friends') {
    bgClass = "bg-red-50 border-red-400";
    textClass = "text-red-500";
    icon = "❌";
    label = "Unfriend";
  }

  return (
    <TouchableOpacity 
      onPress={handlePress}
      disabled={isLoading}
      className={`w-full p-[15px] rounded-[15px] items-center flex-row justify-center mt-[10px] border-2 ${bgClass}`}
    >
      {isLoading ? (
        <ActivityIndicator color={status === 'none' ? '#4CAF50' : (status === 'pending' ? '#CA8A04' : '#EF4444')} />
      ) : (
        <>
          <Text className="text-[20px] mr-2">{icon}</Text>
          <Text className={`text-[16px] font-bold ${textClass}`}>{label}</Text>
        </>
      )}
    </TouchableOpacity>
  );
};