import React, { useState } from 'react';
import { TouchableOpacity, Text, Alert, ActivityIndicator } from 'react-native';

// 🚨 MATCH THIS TO YOUR API URL
const API_URL = "http://10.0.2.2:3000";

interface DeleteAccountProps {
  userId: string;
  onSuccess?: () => void; // Triggered after successful deletion (e.g., to log the user out)
}

export const DeleteAccountButton = ({ userId, onSuccess }: DeleteAccountProps) => {
  const [isDeleting, setIsDeleting] = useState(false);

  const handleDelete = () => {
    Alert.alert(
      "⚠️ Delete Account",
      "Are you absolutely sure? This action cannot be undone. All your matches, messages, and photos will be permanently erased.",
      [
        { text: "Cancel", style: "cancel" },
        {
          text: "Delete Forever",
          style: "destructive",
          onPress: async () => {
            setIsDeleting(true);
            try {
              // Call your backend API to delete the user from the PostgreSQL database
              const res = await fetch(`${API_URL}/api/users/delete`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ userId })
              });

              if (res.ok) {
                Alert.alert("Account Deleted", "Your account has been permanently removed.");
                if (onSuccess) onSuccess(); 
              } else {
                Alert.alert("Error", "Could not delete account. Please try again.");
              }
            } catch (error) {
              console.error("Delete Account Error:", error);
              Alert.alert("Network Error", "Could not reach the server.");
            } finally {
              setIsDeleting(false);
            }
          }
        }
      ]
    );
  };

  return (
    <TouchableOpacity 
      className="bg-red-600 p-[18px] rounded-[150px] items-center mx-[15px] mb-[30px] shadow-sm elevation-2" 
      onPress={handleDelete}
      disabled={isDeleting}
    >
      {isDeleting ? (
        <ActivityIndicator color="#ffffff" />
      ) : (
        <Text className="text-white font-black tracking-widest uppercase">Delete My Account</Text>
      )}
    </TouchableOpacity>
  );
};