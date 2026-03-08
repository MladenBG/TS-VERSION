import React, { useState } from 'react';
import { View, Text, TextInput, TouchableOpacity, ScrollView, Image, Alert, Switch, Modal, FlatList, ActivityIndicator } from 'react-native';
import * as ImagePicker from 'expo-image-picker';
import * as ImageManipulator from 'expo-image-manipulator';

// =========================================================================
// 🚨 THE MASTER URL SWITCH 🚨
// =========================================================================
// USE NGROK FOR BOTH EMULATOR AND PHONE AT THE SAME TIME:
//const API_URL = "https://marshall-voltametric-clair.ngrok-free.dev"; 

// COMMENT OUT THE LOCAL IP:
 const API_URL = "http://10.0.2.2:3000"; 
// =========================================================================

// --- DATA LISTS FOR PICKERS ---
const MUSIC_OPTIONS = ["Electronic", "Classical", "Hip-hop", "Dance", "Pop", "Rock", "Metal", "Jazz"];
const EDUCATION_OPTIONS = ["No Education", "High School", "College", "Master", "PhD", "Other"];
const SEXUALITY_OPTIONS = ["Heterosexual", "Gay", "Lesbian", "Bisexual", "Other"];
const BODY_TYPE_OPTIONS = ["Athletic", "Fat", "Normal", "Slim", "Muscular", "Curvy"];
const COUNTRY_OPTIONS = ["Serbia", "USA", "UK", "Germany", "France", "Spain", "Italy", "Croatia", "Japan", "Brazil"];
const CITY_OPTIONS = ["Subotica", "Belgrade", "Novi Sad", "Miami", "London", "Paris", "Berlin", "New York", "Tokyo"];
const HAIR_OPTIONS = ["Black", "Brown", "Blonde", "Red", "Grey", "Bald", "Other"];
const EYE_OPTIONS = ["Brown", "Blue", "Green", "Hazel", "Grey", "Other"];
const HEIGHT_OPTIONS = Array.from({length: 81}, (_, i) => `${i + 140} cm`); 
const WEIGHT_OPTIONS = Array.from({length: 111}, (_, i) => `${i + 40} kg`); 
const DAYS = Array.from({length: 31}, (_, i) => `${i + 1}`);
const MONTHS = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
const YEARS = Array.from({length: 70}, (_, i) => `${2006 - i}`);

export const EditProfile = ({ 
  myName, setMyName, 
  myCity, setMyCity, 
  isPrivate, setIsPrivate, 
  notificationsEnabled, setNotificationsEnabled, 
  setShowPaywall 
}: any) => {
  
  const currentUserId = "my_test_id"; // 🚨 Same test ID we used in SafetyMenu.tsx

  // --- LOCAL STATE FOR PROFILE FIELDS ---
  const [bio, setBio] = useState('');
  const [country, setCountry] = useState('Serbia');
  const [music, setMusic] = useState('Electronic');
  const [education, setEducation] = useState('College');
  const [sexuality, setSexuality] = useState('Heterosexual');
  const [bodyType, setBodyType] = useState('Normal');
  const [hairColor, setHairColor] = useState('Brown');
  const [eyeColor, setEyeColor] = useState('Brown');
  const [weight, setWeight] = useState('75 kg');
  const [height, setHeight] = useState('180 cm');
  
  const [day, setDay] = useState('1');
  const [month, setMonth] = useState('January');
  const [year, setYear] = useState('2000');

  // --- IMAGE UPLOAD STATE ---
  const [avatarUrl, setAvatarUrl] = useState('https://picsum.photos/200');
  const [isUploading, setIsUploading] = useState(false);

  // --- PICKER MODAL STATE ---
  const [pickerVisible, setPickerVisible] = useState(false);
  const [pickerData, setPickerData] = useState<string[]>([]);
  const [pickerTitle, setPickerTitle] = useState('');
  const [currentField, setCurrentField] = useState('');

  // 🚀 --- BLOCKED USERS STATE --- 🚀
  const [showBlockedModal, setShowBlockedModal] = useState(false);
  const [blockedUsers, setBlockedUsers] = useState<any[]>([]);

  const openPicker = (title: string, data: string[], field: string) => {
    setPickerTitle(title);
    setPickerData(data);
    setCurrentField(field);
    setPickerVisible(true);
  };

  const handleSelect = (item: string) => {
    if (currentField === 'music') setMusic(item);
    if (currentField === 'education') setEducation(item);
    if (currentField === 'sexuality') setSexuality(item);
    if (currentField === 'bodyType') setBodyType(item);
    if (currentField === 'country') setCountry(item);
    if (currentField === 'city') setMyCity(item);
    if (currentField === 'hair') setHairColor(item);
    if (currentField === 'eye') setEyeColor(item);
    if (currentField === 'height') setHeight(item);
    if (currentField === 'weight') setWeight(item);
    if (currentField === 'day') setDay(item);
    if (currentField === 'month') setMonth(item);
    if (currentField === 'year') setYear(item);
    setPickerVisible(false);
  };

  const handleImageUpload = async () => {
    const permissionResult = await ImagePicker.requestMediaLibraryPermissionsAsync();
    
    if (permissionResult.granted === false) {
      Alert.alert("Permission Required", "Allow access to photos to change your profile picture.");
      return;
    }

    const result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ['images'], 
      allowsEditing: true,
      aspect: [1, 1],
      quality: 1,
    });

    if (!result.canceled && result.assets && result.assets.length > 0) {
      setIsUploading(true);
      try {
        const manipResult = await ImageManipulator.manipulateAsync(
          result.assets[0].uri,
          [{ resize: { width: 500 } }],
          { compress: 0.7, format: ImageManipulator.SaveFormat.WEBP }
        );

        // 🚨 UPDATED TO USE API_URL
        const response = await fetch(`${API_URL}/api/get-upload-url`);
        const { uploadUrl, publicUrl } = await response.json();

        const imageResponse = await fetch(manipResult.uri);
        const blob = await imageResponse.blob();
        
        const uploadRes = await fetch(uploadUrl, {
          method: 'PUT',
          body: blob,
          headers: { 'Content-Type': 'image/webp' },
        });

        if (uploadRes.ok) {
          setAvatarUrl(publicUrl);
          Alert.alert("Looking Good!", "Profile picture successfully updated.");
        } else {
          throw new Error("Cloudflare rejected the upload");
        }
      } catch (error) {
        console.error("Profile Pic Upload Error:", error);
        Alert.alert("Upload Failed", "Could not update profile picture. Make sure your server is running!");
      } finally {
        setIsUploading(false);
      }
    }
  };

  // 🚀 FETCH BLOCKED USERS WHEN THEY OPEN THE MODAL
  const openBlockedUsers = async () => {
    setShowBlockedModal(true);
    try {
      // 🚨 UPDATED TO USE API_URL
      const res = await fetch(`${API_URL}/api/blocks/${currentUserId}`);
      if (res.ok) {
        const data = await res.json();
        setBlockedUsers(data);
      }
    } catch (e) {
      console.error("Failed to fetch blocked users");
    }
  };

  // 🚀 UNBLOCK A USER
  const handleUnblock = async (blockedId: string) => {
    try {
      // 🚨 UPDATED TO USE API_URL
      const res = await fetch(`${API_URL}/api/unblock`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ blockerId: currentUserId, blockedId })
      });
      if (res.ok) {
        setBlockedUsers(prev => prev.filter(u => u.id !== blockedId));
        Alert.alert("Unblocked", "This person has been removed from your block list.");
      }
    } catch (e) {
      Alert.alert("Error", "Could not unblock user.");
    }
  };

  return (
    <View className="flex-1">
      <ScrollView className="p-5">
        
        {/* PROFILE PICTURE */}
        <View className="items-center mb-7">
          <TouchableOpacity onPress={handleImageUpload} className="items-center" disabled={isUploading}>
            {isUploading ? (
              <View className="w-[120px] h-[120px] rounded-full mb-2.5 bg-gray-200 items-center justify-center">
                <ActivityIndicator size="large" color="#4CAF50" />
              </View>
            ) : (
              <Image source={{uri: avatarUrl}} className="w-[120px] h-[120px] rounded-full mb-2.5 border-2 border-[#EEE]" />
            )}
            <Text className="text-[#4CAF50] font-bold mt-2.5 text-[16px]">
              {isUploading ? "Uploading to Cloud..." : "Change Picture"}
            </Text>
          </TouchableOpacity>
        </View>
        
        {/* BASIC INFO */}
        <Text className="text-[12px] text-[#999] mx-[15px] mt-[10px] mb-[5px]">Display Name</Text>
        <TextInput className="h-[45px] bg-[#FFF] rounded-[10px] px-[15px] border border-[#DDD] mx-[15px] mb-[10px] text-black" value={myName} onChangeText={setMyName} placeholder="Enter your name" placeholderTextColor="#999" />
        
        <Text className="text-[12px] text-[#999] mx-[15px] mt-[10px] mb-[5px]">Bio / About Me</Text>
        <TextInput 
          className="h-[100px] bg-[#FFF] rounded-[10px] p-[15px] border border-[#DDD] mx-[15px] mb-[10px] text-black" 
          value={bio} 
          onChangeText={setBio} 
          placeholder="Write something about yourself..." 
          placeholderTextColor="#999"
          multiline={true}
          numberOfLines={4}
          style={{ textAlignVertical: 'top' }}
        />

        {/* DATE OF BIRTH */}
        <Text className="text-[12px] text-[#999] mx-[15px] mt-[10px] mb-[5px]">Date of Birth</Text>
        <View className="flex-row justify-between items-center">
          <TouchableOpacity className="flex-1 h-[45px] bg-[#FFF] rounded-[10px] px-[15px] border border-[#DDD] mx-[15px] mb-[10px] justify-center" onPress={() => openPicker('Day', DAYS, 'day')}>
            <Text className="text-[#333] text-[14px]">{day}</Text>
          </TouchableOpacity>
          <TouchableOpacity className="flex-1 h-[45px] bg-[#FFF] rounded-[10px] px-[15px] border border-[#DDD] mx-[15px] mb-[10px] justify-center" onPress={() => openPicker('Month', MONTHS, 'month')}>
            <Text className="text-[#333] text-[14px]">{month}</Text>
          </TouchableOpacity>
          <TouchableOpacity className="flex-1 h-[45px] bg-[#FFF] rounded-[10px] px-[15px] border border-[#DDD] mx-[15px] mb-[10px] justify-center" onPress={() => openPicker('Year', YEARS, 'year')}>
            <Text className="text-[#333] text-[14px]">{year}</Text>
          </TouchableOpacity>
        </View>

        {/* LOCATION */}
        <View className="flex-row justify-between items-center">
          <View className="flex-1">
            <Text className="text-[12px] text-[#999] mx-[15px] mt-[10px] mb-[5px]">Country</Text>
            <TouchableOpacity className="h-[45px] bg-[#FFF] rounded-[10px] px-[15px] border border-[#DDD] mx-[15px] mb-[10px] justify-center" onPress={() => openPicker('Country', COUNTRY_OPTIONS, 'country')}>
              <Text className="text-[#333] text-[14px]">{country}</Text>
            </TouchableOpacity>
          </View>
          <View className="flex-1">
            <Text className="text-[12px] text-[#999] mx-[15px] mt-[10px] mb-[5px]">Town / City</Text>
            <TouchableOpacity className="h-[45px] bg-[#FFF] rounded-[10px] px-[15px] border border-[#DDD] mx-[15px] mb-[10px] justify-center" onPress={() => openPicker('Town / City', CITY_OPTIONS, 'city')}>
              <Text className="text-[#333] text-[14px]">{myCity}</Text>
            </TouchableOpacity>
          </View>
        </View>

        {/* SETTINGS TOGGLES */}
        <View className="flex-row justify-between items-center my-4 pb-4 border-b border-[#F5F5F5] px-[15px]">
          <View>
            <Text className="text-[#333] font-bold text-[16px]">Global Notifications</Text>
            <Text className="text-[12px] text-[#999]">Alerts for matches and lobby</Text>
          </View>
          <Switch value={notificationsEnabled} onValueChange={setNotificationsEnabled} trackColor={{true: '#4CAF50'}} />
        </View>

        {/* BUTTONS */}
        <TouchableOpacity className="bg-[#4CAF50] p-[18px] rounded-[150px] items-center m-[15px]" onPress={() => Alert.alert("Dateroot", "Profile Updated Successfully!")}>
          <Text className="text-white font-bold">Save Profile Changes</Text>
        </TouchableOpacity>

        {/* 🚀 THE NEW MANAGE BLOCKED USERS BUTTON 🚀 */}
        <TouchableOpacity className="bg-red-50 p-[18px] rounded-[150px] items-center mx-[15px] mb-[15px] border border-red-200" onPress={openBlockedUsers}>
          <Text className="text-red-600 font-bold">🚫 Manage Blocked Users</Text>
        </TouchableOpacity>

        <TouchableOpacity className="bg-black p-[18px] rounded-[150px] items-center m-[15px] mb-[50px]" onPress={() => setShowPaywall(true)}>
          <Text className="text-white font-bold">Manage VIP Subscription</Text>
        </TouchableOpacity>
      </ScrollView>

      {/* REUSABLE PICKER MODAL */}
      <Modal visible={pickerVisible} animationType="slide" transparent={true}>
        <View className="flex-1 bg-black/60 justify-end">
          <View className="bg-white rounded-t-[20px] max-h-[50%]">
            <View className="flex-row justify-between p-5 border-b border-[#EEE] items-center">
              <Text className="text-[18px] font-bold text-[#333]">Select {pickerTitle}</Text>
              <TouchableOpacity onPress={() => setPickerVisible(false)}>
                <Text className="text-[24px] text-[#333]">✕</Text>
              </TouchableOpacity>
            </View>
            <FlatList 
              data={pickerData}
              keyExtractor={(item, index) => index.toString()}
              renderItem={({item}) => (
                <TouchableOpacity className="p-[18px] border-b border-[#EEE]" onPress={() => handleSelect(item)}>
                  <Text className="text-[16px] text-center text-black">{item}</Text>
                </TouchableOpacity>
              )}
            />
          </View>
        </View>
      </Modal>

      {/* 🚀 BLOCKED USERS LIST MODAL 🚀 */}
      <Modal visible={showBlockedModal} animationType="slide" transparent={true}>
        <View className="flex-1 bg-black/60 justify-end">
          <View className="bg-white rounded-t-[24px] h-[70%] p-5 pb-10">
            <View className="flex-row justify-between items-center mb-4 border-b border-gray-100 pb-4">
              <Text className="text-[20px] font-black text-gray-800">🚫 Blocked Accounts</Text>
              <TouchableOpacity onPress={() => setShowBlockedModal(false)}>
                <Text className="text-[24px] text-gray-400 font-bold">✕</Text>
              </TouchableOpacity>
            </View>

            {blockedUsers.length === 0 ? (
              <Text className="text-center text-gray-400 font-bold mt-10 text-lg">You haven't blocked anyone.</Text>
            ) : (
              <FlatList 
                data={blockedUsers}
                keyExtractor={(item) => item.id.toString()}
                renderItem={({item}) => (
                  <View className="flex-row items-center justify-between p-4 mb-2 bg-gray-50 rounded-2xl border border-gray-100">
                    <View className="flex-row items-center flex-1">
                      <Image source={{uri: item.image}} className="w-[45px] h-[45px] rounded-full mr-3 border border-gray-200" />
                      <Text className="font-bold text-gray-800 text-[16px] flex-shrink" numberOfLines={1}>{item.name}</Text>
                    </View>
                    <TouchableOpacity 
                      onPress={() => handleUnblock(item.id)}
                      className="bg-gray-200 py-2.5 px-5 rounded-full"
                    >
                      <Text className="font-bold text-gray-700 text-xs">Unblock</Text>
                    </TouchableOpacity>
                  </View>
                )}
              />
            )}
          </View>
        </View>
      </Modal>

    </View>
  );
};