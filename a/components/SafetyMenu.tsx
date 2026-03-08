import React, { useState } from 'react';
import { View, Text, TouchableOpacity, Alert, Modal } from 'react-native';

export const SafetyMenu = ({ viewedUserId }: { viewedUserId: string }) => {
  const [showMenu, setShowMenu] = useState(false);
  const currentUserId = "my_test_id"; // We will link this to your real profile later!

  const handleBlock = async () => {
    try {
      const response = await fetch('http://192.168.8.104:3001/api/block', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ blockerId: currentUserId, blockedId: viewedUserId })
      });
      if (response.ok) {
        Alert.alert("Blocked", "You will no longer see this person on DateRoot.");
        setShowMenu(false);
      }
    } catch (e) {
      Alert.alert("Error", "Could not block user.");
    }
  };

  const submitReport = async (reason: string) => {
    try {
      const response = await fetch('http://192.168.8.104:3001/api/report', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ reporterId: currentUserId, reportedId: viewedUserId, reason })
      });
      if (response.ok) {
        Alert.alert("Reported", "Our admin team will review this profile.");
        setShowMenu(false);
      }
    } catch (e) {
      Alert.alert("Error", "Could not send report.");
    }
  };

  const handleReport = () => {
    Alert.alert("Report User", "Why are you reporting this profile?", [
      { text: "Inappropriate Content", onPress: () => submitReport("Inappropriate Content") },
      { text: "Fake Profile / Spam", onPress: () => submitReport("Fake Profile") },
      { text: "Harassment", onPress: () => submitReport("Harassment") },
      { text: "Cancel", style: "cancel" }
    ]);
  };

  return (
    <>
      <TouchableOpacity 
        onPress={() => setShowMenu(true)} 
        className="w-8 h-8 bg-black/40 rounded-full items-center justify-center"
      >
        <Text className="text-white text-lg font-bold leading-none -mt-1">⋮</Text>
      </TouchableOpacity>

      <Modal visible={showMenu} transparent animationType="slide">
        <View className="flex-1 justify-end bg-black/60">
          <View className="bg-white rounded-t-3xl p-6 pb-10">
            <Text className="text-xl font-black text-center mb-6 text-gray-800">Safety Options</Text>
            
            <TouchableOpacity onPress={handleReport} className="bg-red-50 p-4 rounded-xl border border-red-200 mb-3 items-center">
              <Text className="text-red-600 font-bold text-lg">🚩 Report User</Text>
            </TouchableOpacity>

            <TouchableOpacity onPress={handleBlock} className="bg-gray-100 p-4 rounded-xl border border-gray-200 mb-3 items-center">
              <Text className="text-gray-700 font-bold text-lg">🚫 Block User</Text>
            </TouchableOpacity>

            <TouchableOpacity onPress={() => setShowMenu(false)} className="p-4 items-center mt-2">
              <Text className="text-gray-500 font-bold text-lg">Cancel</Text>
            </TouchableOpacity>
          </View>
        </View>
      </Modal>
    </>
  );
};