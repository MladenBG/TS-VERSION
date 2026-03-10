import React, { useState } from 'react';
import { 
  Modal, View, Text, TouchableOpacity, ScrollView, 
  Image, KeyboardAvoidingView, TextInput, Platform, 
  FlatList, Dimensions, Alert 
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { Friends } from './Friends';
import { ImageGallery } from './ImageGallery';
import { GiftsReceived } from './GiftsReceived';
import { FriendActionButton } from './FriendActionButton'; 

const { height } = Dimensions.get('window');
const API_URL = "http://10.0.2.2:3001"; 

export const AllModals = ({ 
  showFilters, setShowFilters, filterGender, setFilterGender, filterSexuality, setFilterSexuality, SEXUALITIES, setCurrentPage,
  selectedUser, setSelectedUser, toggleLike, profiles, setChatUser,
  chatUser, setChatUserModal, messages, setMessages, chatInput, setChatInput, handleSendMessage, 
  navigation, 
  handleAddFriend, 
  handleSendGift,
  handleStartVideoCall,
  myId, 
  myImage,
  isAdmin,          
  isVip,            
  setShowPaywall,   
  totalFreeMessages,     
  setTotalFreeMessages   
}: any) => {

  const onSendPrivateMessage = () => {
    if (!isAdmin && !isVip && totalFreeMessages >= 2) {
      Alert.alert(
        "Out of Free Messages! 🛑", 
        "You have used your 2 free messages across the app. Subscribe to VIP to chat unlimited!",
        [
          { text: "Cancel", style: "cancel" },
          { text: "Unlock VIP", onPress: () => {
              setChatUserModal(null); 
              if (setShowPaywall) setShowPaywall(true); 
            } 
          }
        ]
      );
      return; 
    }

    if (chatInput.trim()) {
      handleSendMessage(); 
      
      if (!isAdmin && !isVip) {
        setTotalFreeMessages((prev: number) => prev + 1);
      }
    }
  };

  const placeholderText = (!isAdmin && !isVip) 
    ? `Write a message... (${Math.max(0, 2 - totalFreeMessages)} left)` 
    : "Write a message...";

  const confirmDeleteMessage = (messageId: string, userId: string) => {
    Alert.alert(
      "Delete Message",
      "Are you sure you want to delete this message for everyone?",
      [
        { text: "Cancel", style: "cancel" },
        { 
          text: "Delete", 
          style: "destructive", 
          onPress: () => deleteMessage(messageId, userId) 
        }
      ]
    );
  };

  const deleteMessage = async (messageId: string, userId: string) => {
    const updatedMessages = (messages[userId] || []).filter((m: any) => m.id !== messageId);
    setMessages({
      ...messages,
      [userId]: updatedMessages
    });

    try {
      await fetch(`${API_URL}/api/messages?id=${messageId}`, {
        method: 'DELETE',
      });
    } catch (error) {
      console.error("Failed to delete from DB:", error);
    }
  };

  const handleReportUser = () => {
    Alert.alert(
      "Report User",
      `Are you sure you want to report ${chatUser?.name}? This will notify the admin team immediately.`,
      [
        { text: "Cancel", style: "cancel" },
        { 
          text: "Report", 
          style: "destructive", 
          onPress: async () => {
            try {
              await fetch(`${API_URL}/api/admin/reports`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ 
                  reporter_id: myId, 
                  reported_id: chatUser.id, 
                  reason: "Inappropriate behavior in private chat" 
                })
              });
              Alert.alert("Reported", "The admin team has been notified. Thank you for keeping DateRoot safe.");
            } catch (error) {
              console.error("Failed to report:", error);
            }
          } 
        }
      ]
    );
  };

  const handleBlockUser = () => {
    Alert.alert(
      "Block User",
      `Are you sure you want to block ${chatUser?.name}? You will no longer receive messages from them.`,
      [
        { text: "Cancel", style: "cancel" },
        { 
          text: "Block", 
          style: "destructive", 
          onPress: async () => {
            try {
              await fetch(`${API_URL}/api/users/block`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ 
                  blocker_id: myId, 
                  blocked_id: chatUser.id 
                })
              });
              Alert.alert("Blocked", `${chatUser.name} has been blocked.`);
              setChatUserModal(null); 
            } catch (error) {
              Alert.alert("Blocked", `${chatUser.name} has been blocked.`);
              setChatUserModal(null);
            }
          } 
        }
      ]
    );
  };

  const openChatOptions = () => {
    Alert.alert(
      "Chat Options",
      `What would you like to do with ${chatUser?.name}?`,
      [
        { text: "Report User", style: "destructive", onPress: handleReportUser },
        { text: "Block User", style: "destructive", onPress: handleBlockUser },
        { text: "Cancel", style: "cancel" }
      ]
    );
  };

  return (
    <>
      {/* FILTER MODAL */}
      <Modal visible={showFilters} animationType="slide" transparent={true}>
        <View className="flex-1 bg-black/50 justify-end">
          <View className="bg-white rounded-t-[30px] p-[25px]">
            <View className="flex-row justify-between mb-5">
              <Text className="text-[20px] font-bold text-black">Discovery Filters</Text>
              <TouchableOpacity onPress={() => setShowFilters(false)}>
                <Text className="text-[24px] text-black">✕</Text>
              </TouchableOpacity>
            </View>
            
            <Text className="text-[16px] font-bold mt-[15px] mb-2.5 text-black">Show Me</Text>
            <View className="flex-row mb-2.5">
              {['All', 'Man', 'Woman', 'Non-binary'].map(g => (
                <TouchableOpacity 
                  key={g} 
                  onPress={() => {setFilterGender(g); setCurrentPage(1);}} 
                  className={`py-2.5 px-5 rounded-[20px] mr-2.5 ${filterGender === g ? 'bg-[#4CAF50]' : 'bg-[#F5F5F5]'}`}
                >
                  <Text className={`font-bold ${filterGender === g ? 'text-white' : 'text-[#333]'}`}>{g}</Text>
                </TouchableOpacity>
              ))}
            </View>

            <Text className="text-[16px] font-bold mt-[15px] mb-2.5 text-black">Orientation Preference</Text>
            <ScrollView horizontal showsHorizontalScrollIndicator={false} className="flex-row mb-2.5">
              {['All', ...SEXUALITIES].map(s => (
                <TouchableOpacity 
                  key={s} 
                  onPress={() => {setFilterSexuality(s); setCurrentPage(1);}} 
                  className={`py-2.5 px-5 rounded-[20px] mr-2.5 ${filterSexuality === s ? 'bg-[#4CAF50]' : 'bg-[#F5F5F5]'}`}
                >
                  <Text className={`font-bold ${filterSexuality === s ? 'text-white' : 'text-[#333]'}`}>{s}</Text>
                </TouchableOpacity>
              ))}
            </ScrollView>

            <TouchableOpacity 
              className="bg-[#4CAF50] p-[15px] rounded-[15px] items-center mt-[30px]" 
              onPress={() => setShowFilters(false)}
            >
              <Text className="text-white font-bold">Apply New Filters</Text>
            </TouchableOpacity>
          </View>
        </View>
      </Modal>

      {/* DETAIL MODAL (PUBLIC PROFILE) */}
      <Modal visible={!!selectedUser} animationType="slide">
        <SafeAreaView className="flex-1 bg-white">
          {selectedUser && (
            <View className="flex-1 relative">
              <Image 
                source={{ uri: 'love4.webp' }} 
                className="absolute w-full h-full opacity-5 pointer-events-none" 
                resizeMode="cover" 
              />
              <View className="p-[15px] border-b border-[#EEE]">
                <TouchableOpacity onPress={() => setSelectedUser(null)} className="p-2.5 z-10">
                  <Text className="text-[#4CAF50] font-bold">← Back to World</Text>
                </TouchableOpacity>
              </View>
              <ScrollView showsVerticalScrollIndicator={false}>
                <Image source={{ uri: selectedUser.image }} className="w-full" style={{ height: height * 0.5 }} />
                <View className="p-[20px]">
                  <View className="flex-row justify-between items-center">
                    <Text className="text-[28px] font-bold text-black">{selectedUser.name}, {selectedUser.age}</Text>
                    <TouchableOpacity onPress={() => toggleLike(selectedUser.id)}>
                      <Text className="text-[40px]">{selectedUser.isFavorite ? '❤️' : '🤍'}</Text>
                    </TouchableOpacity>
                  </View>
                  <Text className="text-[16px] text-[#666] mt-1">{selectedUser.town} • {selectedUser.gender} ({selectedUser.sexuality})</Text>
                  <Text className="text-[16px] text-[#444] mt-[15px] mb-[20px] leading-6">{selectedUser.bio}</Text>
                  
                  {/* 🚀 ALL DUMMY DATA HAS BEEN RIPPED OUT. ONLY LOADS REAL DATABASE DATA NOW. 🚀 */}
                  
                  <ImageGallery 
                    initialImages={selectedUser?.gallery?.length > 0 ? selectedUser.gallery : [selectedUser?.image]} 
                    isPublicView={true} 
                  />
                  
                  <Friends 
                    friendsList={selectedUser?.friends || []} 
                    isAdmin={isAdmin}
                    isVip={isVip}
                    setShowPaywall={() => {
                      setSelectedUser(null); 
                      if (setShowPaywall) setShowPaywall(true); 
                    }}
                  />

                  <GiftsReceived 
                    gifts={selectedUser?.gifts || []} 
                    isAdmin={isAdmin}
                    isVip={isVip}
                    setShowPaywall={() => {
                      setSelectedUser(null); 
                      if (setShowPaywall) setShowPaywall(true); 
                    }}
                  />

                  <FriendActionButton 
                    selectedUser={selectedUser}
                    myId={myId}
                    isAdmin={isAdmin}
                    isVip={isVip}
                    onRequirePaywall={() => {
                      setSelectedUser(null); 
                      if (setShowPaywall) setShowPaywall(true); 
                    }}
                  />

                  <View className="mt-[20px] bg-pink-50/50 p-5 rounded-[20px] border border-pink-100">
                    <Text className="text-[11px] font-black mb-4 text-pink-400 text-center tracking-widest uppercase">Send a Private Gift</Text>
                    <View className="flex-row justify-center items-center">
                      {['🌹', '💍', '🐻', '🥂'].map(gift => (
                        <TouchableOpacity 
                          key={gift}
                          onPress={() => {
                            if (!isAdmin && !isVip) {
                              setSelectedUser(null); 
                            }
                            handleSendGift(selectedUser, gift);
                          }}
                          className="bg-white w-14 h-14 rounded-full border border-pink-200 shadow-sm mx-2 items-center justify-center elevation-2"
                        >
                          <Text className="text-[28px]">{gift}</Text>
                        </TouchableOpacity>
                      ))}
                    </View>
                  </View>

                  <View className="mt-[30px]">
                    <Text className="text-[18px] font-bold mb-[15px] text-black">{selectedUser.name.split(' ')[0]}'s Top Connections</Text>
                    <ScrollView horizontal showsHorizontalScrollIndicator={false}>
                      {profiles.filter((p: any) => !p.isBanned).slice(10, 20).map((fav: any) => (
                        <View key={fav.id} className="mr-[15px] items-center">
                          <Image source={{uri: fav.image}} className="w-[60px] h-[60px] rounded-[30px]" />
                          <Text className="text-[10px] mt-1 text-[#666]">{fav.name.split(' ')[0]}</Text>
                        </View>
                      ))}
                    </ScrollView>
                  </View>

                  <TouchableOpacity 
                    className="bg-[#4CAF50] p-[18px] rounded-[150px] items-center m-[15px] mt-[30px]" 
                    onPress={() => { setChatUser(selectedUser); setSelectedUser(null); }}
                  >
                    <Text className="text-white font-bold">Start Direct Message</Text>
                  </TouchableOpacity>
                </View>
              </ScrollView>
            </View>
          )}
        </SafeAreaView>
      </Modal>

      {/* CHAT MODAL */}
      <Modal visible={!!chatUser} animationType="fade">
        <SafeAreaView className="flex-1 bg-white relative">
          <Image 
            source={{ uri: 'love4.webp' }} 
            className="absolute w-full h-full opacity-5 pointer-events-none" 
            resizeMode="cover" 
          />

          <KeyboardAvoidingView behavior={Platform.OS === 'ios' ? 'padding' : undefined} className="flex-1">
            <View className="flex-row justify-between items-center p-[20px] border-b border-[#EEE] bg-white/90">
              <TouchableOpacity onPress={() => setChatUserModal(null)}>
                <Text className="text-[#4CAF50] font-bold">← Close</Text>
              </TouchableOpacity>
              
              <View className="items-center ml-4">
                <Text className="text-[18px] font-bold text-black">{chatUser?.name}</Text>
                <Text className="text-[10px] text-green-500">Online Now</Text>
              </View>

              <View className="flex-row items-center">
                {/* Video Call Button */}
                <TouchableOpacity 
                  onPress={() => {
                    setChatUserModal(null);
                    handleStartVideoCall(chatUser);
                  }}
                  className="mr-3"
                >
                  <Text className="text-[26px]">📹</Text>
                </TouchableOpacity>

                <TouchableOpacity 
                  onPress={openChatOptions} 
                  className="mr-3 bg-gray-100 w-[30px] h-[30px] rounded-full items-center justify-center"
                >
                  <Text className="text-[18px] text-gray-600 font-bold leading-[22px]">⋮</Text>
                </TouchableOpacity>

                <Image source={{uri: chatUser?.image}} className="w-[40px] h-[40px] rounded-[20px]" />
              </View>
            </View>

            <FlatList 
              data={chatUser ? (messages[chatUser.id] || []) : []} 
              keyExtractor={(item) => item.id} 
              renderItem={({item}) => (
                <TouchableOpacity 
                  onLongPress={() => confirmDeleteMessage(item.id, chatUser.id)}
                  activeOpacity={0.8}
                  className={`p-3 rounded-[20px] max-w-[80%] my-1 ${item.sender === 'me' ? 'self-end bg-[#4CAF50]' : 'self-start bg-[#F0F0F0]'}`}
                >
                  <Text className={`text-[16px] ${item.sender === 'me' ? 'text-white' : 'text-black'}`}>{item.text}</Text>
                </TouchableOpacity>
              )} 
              contentContainerStyle={{padding: 10}}
            />
            
            <View className="flex-row p-[15px] border-t border-[#EEE] bg-white/90">
              <TextInput 
                className="flex-1 h-[45px] bg-[#F5F5F5] rounded-[20px] px-[15px] text-black" 
                placeholder={placeholderText} 
                placeholderTextColor="#999"
                value={chatInput} 
                onChangeText={setChatInput} 
              />
              <TouchableOpacity onPress={onSendPrivateMessage} className="ml-2.5 bg-[#4CAF50] px-[20px] rounded-[20px] justify-center">
                <Text className="text-white font-bold">SEND</Text>
              </TouchableOpacity>
            </View>
          </KeyboardAvoidingView>
        </SafeAreaView>
      </Modal>
    </>
  );
};