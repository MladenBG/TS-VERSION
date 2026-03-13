import React, { useState } from 'react';
import { Modal, View, Text, TouchableOpacity, FlatList, Image } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

interface NotificationItem {
  id: string | number;
  sender_name?: string;
  sender_image?: string;
  content?: string;
  message?: string; // 🚀 THIS IS THE NEW VARIABLE FROM THE SERVER
  type?: string;    // 🚀 TELLS US IF IT IS A GIFT, MESSAGE, ETC.
  created_at: string;
  is_read: boolean;
}

interface NotificationsProps {
  visible: boolean;
  onClose: () => void;
  notifications: NotificationItem[];
  onDelete: (id: string) => void;
}

export const Notifications = ({ visible, onClose, notifications, onDelete }: NotificationsProps) => {
  const [notifPage, setNotifPage] = useState(1);
  
  const NOTIFS_PER_PAGE = 5;
  const notifTotalPages = Math.ceil(notifications.length / NOTIFS_PER_PAGE) || 1;
  const currentNotifs = notifications.slice(
    (notifPage - 1) * NOTIFS_PER_PAGE, 
    notifPage * NOTIFS_PER_PAGE
  );

  // 🚀 ASSIGNS AN EMOJI BASED ON THE NOTIFICATION TYPE 🚀
  const getIconForType = (type?: string) => {
    switch(type) {
      case 'gift': return '🎁';
      case 'new_message': return '💬';
      case 'friend_request': return '👋';
      case 'friend_accepted': return '✅';
      case 'like': return '❤️';
      default: return '🔔';
    }
  };

  return (
    <Modal visible={visible} animationType="slide">
      <SafeAreaView className="flex-1 bg-white">
        
        {/* HEADER */}
        <View className="flex-row items-center justify-between p-5 border-b border-gray-200">
          <TouchableOpacity onPress={onClose}>
            <Text className="text-green-500 font-bold text-lg">← Back</Text>
          </TouchableOpacity>
          <Text className="text-xl font-black text-black">Notifications</Text>
          <View style={{ width: 50 }} />
        </View>
        
        {/* NOTIFICATIONS LIST */}
        <FlatList
          data={currentNotifs}
          keyExtractor={item => item.id.toString()}
          ListEmptyComponent={
            <Text className="text-center mt-10 text-gray-500 font-bold">
              You have no notifications.
            </Text>
          }
          renderItem={({item}) => (
            <View className="flex-row items-center p-4 border-b border-gray-100 mx-2 bg-gray-50 rounded-xl mb-2">
              
              {/* 🚀 AVATAR OR SMART EMOJI ICON 🚀 */}
              {item.sender_image ? (
                <Image 
                  source={{uri: item.sender_image}} 
                  className="w-12 h-12 rounded-full mr-3 border border-gray-200" 
                />
              ) : (
                <View className="w-12 h-12 rounded-full mr-3 bg-white border border-gray-200 items-center justify-center shadow-sm">
                  <Text className="text-2xl">{getIconForType(item.type)}</Text>
                </View>
              )}

              <View className="flex-1">
                {/* 🚀 DISPLAYS THE FULL MESSAGE FROM SERVER: "User sent you a gift!" 🚀 */}
                <Text className="font-bold text-sm text-black">
                  {item.message || item.content || "You have a new notification"}
                </Text>
                
                <Text className="text-xs text-gray-400 mt-1">
                  {new Date(item.created_at).toLocaleString()}
                </Text>
              </View>

              <TouchableOpacity 
                onPress={() => onDelete(item.id.toString())}
                className="w-8 h-8 rounded-full bg-red-100 items-center justify-center ml-2"
              >
                <Text className="text-red-500 font-bold">✖</Text>
              </TouchableOpacity>
            </View>
          )}
        />

        {/* PAGINATION */}
        {notifications.length > NOTIFS_PER_PAGE && (
          <View className="flex-row justify-between items-center p-4 border-t border-gray-200 bg-white">
            <TouchableOpacity 
              onPress={() => setNotifPage(prev => Math.max(prev - 1, 1))} 
              className={`p-3 rounded-lg min-w-[80px] items-center ${notifPage === 1 ? 'bg-gray-300' : 'bg-green-500'}`}
              disabled={notifPage === 1}
            >
              <Text className="text-white font-bold">Prev</Text>
            </TouchableOpacity>
            
            <Text className="text-gray-600 font-bold">
              {notifPage} / {notifTotalPages}
            </Text>
            
            <TouchableOpacity 
              onPress={() => setNotifPage(prev => Math.min(prev + 1, notifTotalPages))} 
              className={`p-3 rounded-lg min-w-[80px] items-center ${notifPage === notifTotalPages ? 'bg-gray-300' : 'bg-green-500'}`}
              disabled={notifPage === notifTotalPages}
            >
              <Text className="text-white font-bold">Next</Text>
            </TouchableOpacity>
          </View>
        )}
        
      </SafeAreaView>
    </Modal>
  );
};