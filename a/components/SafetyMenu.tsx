import React from 'react';
import { View, TouchableOpacity, Text, Alert } from 'react-native';

const API_URL = "http://10.0.2.2:3001";

export const SafetyMenu = ({ viewedUserId, myId }: any) => {
  const handleReport = () => {
    Alert.alert("Report User", "Are you sure you want to report this user?", [
      { text: "Cancel", style: "cancel" },
      { 
        text: "Report", 
        style: "destructive", 
        onPress: async () => {
          try {
            await fetch(`${API_URL}/api/report`, {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({ 
                reporterId: myId, 
                reportedId: viewedUserId, 
                reason: "Inappropriate behavior on profile" 
              })
            });
            Alert.alert("Reported", "The admin team has been notified.");
          } catch (e) {
            console.error("Report failed:", e);
          }
        } 
      }
    ]);
  };

  const handleBlock = () => {
    Alert.alert("Block User", "Are you sure you want to block this user?", [
      { text: "Cancel", style: "cancel" },
      { 
        text: "Block", 
        style: "destructive", 
        onPress: async () => {
          try {
            await fetch(`${API_URL}/api/block`, {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({ 
                blockerId: myId, 
                blockedId: viewedUserId 
              })
            });
            Alert.alert("Blocked", "User has been blocked successfully.");
          } catch (e) {
            console.error("Block failed:", e);
          }
        } 
      }
    ]);
  };

  const showMenu = () => {
    if (!myId) {
       Alert.alert("Error", "You must be fully logged in to perform this action.");
       return;
    }
    
    Alert.alert("Safety Options", "What would you like to do?", [
      { text: "Report User", style: "destructive", onPress: handleReport },
      { text: "Block User", style: "destructive", onPress: handleBlock },
      { text: "Cancel", style: "cancel" }
    ]);
  };

  return (
    <TouchableOpacity 
      onPress={showMenu} 
      className="bg-black/50 w-8 h-8 rounded-full items-center justify-center shadow-sm"
    >
      <Text className="text-white text-lg font-bold mb-1">⋮</Text>
    </TouchableOpacity>
  );
};