import React from 'react';
import { 
  Modal, View, Text, TouchableOpacity, ScrollView, 
  Image, KeyboardAvoidingView, TextInput, Platform, 
  FlatList, Dimensions 
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

const { height } = Dimensions.get('window');

export const AllModals = ({ 
  showFilters, setShowFilters, filterGender, setFilterGender, filterSexuality, setFilterSexuality, SEXUALITIES, setCurrentPage,
  selectedUser, setSelectedUser, toggleLike, profiles, setChatUser,
  chatUser, setChatUserModal, messages, chatInput, setChatInput, handleSendMessage,
  navigation, // This is the navigationRef from App.tsx
  handleAddFriend // 🚀 ADDED THIS PROP
}: any) => {

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

      {/* DETAIL MODAL */}
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
              <ScrollView>
                <Image source={{ uri: selectedUser.image }} className="w-full" style={{ height: height * 0.5 }} />
                <View className="p-[20px]">
                  <View className="flex-row justify-between items-center">
                    <Text className="text-[28px] font-bold text-black">{selectedUser.name}, {selectedUser.age}</Text>
                    <TouchableOpacity onPress={() => toggleLike(selectedUser.id)}>
                      <Text className="text-[40px]">{selectedUser.isFavorite ? '❤️' : '🤍'}</Text>
                    </TouchableOpacity>
                  </View>
                  <Text className="text-[16px] text-[#666] mt-1">{selectedUser.town} • {selectedUser.gender} ({selectedUser.sexuality})</Text>
                  <Text className="text-[16px] text-[#444] mt-[15px] leading-6">{selectedUser.bio}</Text>
                  
                  {/* 🚀 THE NEW VIP ADD FRIEND BUTTON 🚀 */}
                  <TouchableOpacity 
                    onPress={() => handleAddFriend(selectedUser)}
                    className="w-full bg-[#E8F5E9] p-[15px] rounded-[15px] items-center flex-row justify-center mt-[20px] border-2 border-[#4CAF50]"
                  >
                    <Text className="text-[20px] mr-2">🤝</Text>
                    <Text className="text-[16px] font-bold text-[#4CAF50]">Add as Friend (VIP)</Text>
                  </TouchableOpacity>

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
                    className="bg-[#4CAF50] p-[18px] rounded-[150px] items-center m-[15px]" 
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
              
              <View className="items-center">
                <Text className="text-[18px] font-bold text-black">{chatUser?.name}</Text>
                <Text className="text-[10px] text-green-500">Online Now</Text>
              </View>

              <View className="flex-row items-center">
                {/* VIDEO CALL BUTTON - YOUR EXACT LOGIC REMAINS UNTOUCHED */}
                <TouchableOpacity 
                  onPress={() => {
                    if (navigation?.current) {
                        setChatUserModal(null);
                        navigation.current.navigate('VideoCall', { 
                          userID: 'dateroot_user_1', 
                          userName: 'Me', 
                          callID: `room_${chatUser?.id}`,
                          chatUserName: chatUser?.name
                        });
                    }
                  }}
                  className="mr-4"
                >
                  <Text className="text-[26px]">📹</Text>
                </TouchableOpacity>

                <Image source={{uri: chatUser?.image}} className="w-[40px] h-[40px] rounded-[20px]" />
              </View>
            </View>

            <FlatList 
              data={chatUser ? (messages[chatUser.id] || []) : []} 
              keyExtractor={(_, i) => i.toString()} 
              renderItem={({item}) => (
                <View className={`p-3 rounded-[20px] max-w-[80%] my-1 ${item.sender === 'me' ? 'self-end bg-[#4CAF50]' : 'self-start bg-[#F0F0F0]'}`}>
                  <Text className={`text-[16px] ${item.sender === 'me' ? 'text-white' : 'text-black'}`}>{item.text}</Text>
                </View>
              )} 
              contentContainerStyle={{padding: 10}}
            />
            
            <View className="flex-row p-[15px] border-t border-[#EEE] bg-white/90">
              <TextInput 
                className="flex-1 h-[45px] bg-[#F5F5F5] rounded-[20px] px-[15px] text-black" 
                placeholder="Write a message..." 
                placeholderTextColor="#999"
                value={chatInput} 
                onChangeText={setChatInput} 
              />
              <TouchableOpacity onPress={handleSendMessage} className="ml-2.5 bg-[#4CAF50] px-[20px] rounded-[20px] justify-center">
                <Text className="text-white font-bold">SEND</Text>
              </TouchableOpacity>
            </View>
          </KeyboardAvoidingView>
        </SafeAreaView>
      </Modal>
    </>
  );
};