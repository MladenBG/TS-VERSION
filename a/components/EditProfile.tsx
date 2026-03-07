import React, { useState } from 'react';
import { View, Text, TextInput, TouchableOpacity, ScrollView, Image, Alert, Switch, Modal, FlatList, ActivityIndicator } from 'react-native';
import * as ImagePicker from 'expo-image-picker';
import * as ImageManipulator from 'expo-image-manipulator';

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

  // 🚀 REAL CLOUDFLARE UPLOAD LOGIC 🚀
  const handleImageUpload = async () => {
    const permissionResult = await ImagePicker.requestMediaLibraryPermissionsAsync();
    
    if (permissionResult.granted === false) {
      Alert.alert("Permission Required", "Allow access to photos to change your profile picture.");
      return;
    }

    const result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ImagePicker.MediaTypeOptions.Images,
      allowsEditing: true,
      aspect: [1, 1], // Perfect square crop for circular avatar
      quality: 1,
    });

    if (!result.canceled && result.assets && result.assets.length > 0) {
      setIsUploading(true);
      try {
        // 1. Squash Image to WebP
        const manipResult = await ImageManipulator.manipulateAsync(
          result.assets[0].uri,
          [{ resize: { width: 500 } }], // Resize for avatar
          { compress: 0.7, format: ImageManipulator.SaveFormat.WEBP }
        );

        // 2. Ask Node server for Cloudflare ticket (Make sure port is 3001!)
        // 🚨 Change 10.0.2.2 to your laptop's real IP if testing on a physical phone
        const response = await fetch('http://10.0.2.2:3001/api/get-upload-url');
        const { uploadUrl, publicUrl } = await response.json();

        // 3. Turn into Blob
        const imageResponse = await fetch(manipResult.uri);
        const blob = await imageResponse.blob();
        
        // 4. Send directly to Cloudflare R2
        const uploadRes = await fetch(uploadUrl, {
          method: 'PUT',
          body: blob,
          headers: { 'Content-Type': 'image/webp' },
        });

        if (uploadRes.ok) {
          setAvatarUrl(publicUrl); // Instantly update the image on screen!
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

        {/* PHYSICAL TRAITS */}
        <View className="flex-row justify-between items-center">
          <View className="flex-1">
            <Text className="text-[12px] text-[#999] mx-[15px] mt-[10px] mb-[5px]">Height</Text>
            <TouchableOpacity className="h-[45px] bg-[#FFF] rounded-[10px] px-[15px] border border-[#DDD] mx-[15px] mb-[10px] justify-center" onPress={() => openPicker('Height', HEIGHT_OPTIONS, 'height')}>
              <Text className="text-[#333] text-[14px]">{height}</Text>
            </TouchableOpacity>
          </View>
          <View className="flex-1">
            <Text className="text-[12px] text-[#999] mx-[15px] mt-[10px] mb-[5px]">Weight</Text>
            <TouchableOpacity className="h-[45px] bg-[#FFF] rounded-[10px] px-[15px] border border-[#DDD] mx-[15px] mb-[10px] justify-center" onPress={() => openPicker('Weight', WEIGHT_OPTIONS, 'weight')}>
              <Text className="text-[#333] text-[14px]">{weight}</Text>
            </TouchableOpacity>
          </View>
        </View>

        <View className="flex-row justify-between items-center">
          <View className="flex-1">
            <Text className="text-[12px] text-[#999] mx-[15px] mt-[10px] mb-[5px]">Hair Color</Text>
            <TouchableOpacity className="h-[45px] bg-[#FFF] rounded-[10px] px-[15px] border border-[#DDD] mx-[15px] mb-[10px] justify-center" onPress={() => openPicker('Hair Color', HAIR_OPTIONS, 'hair')}>
              <Text className="text-[#333] text-[14px]">{hairColor}</Text>
            </TouchableOpacity>
          </View>
          <View className="flex-1">
            <Text className="text-[12px] text-[#999] mx-[15px] mt-[10px] mb-[5px]">Eye Color</Text>
            <TouchableOpacity className="h-[45px] bg-[#FFF] rounded-[10px] px-[15px] border border-[#DDD] mx-[15px] mb-[10px] justify-center" onPress={() => openPicker('Eye Color', EYE_OPTIONS, 'eye')}>
              <Text className="text-[#333] text-[14px]">{eyeColor}</Text>
            </TouchableOpacity>
          </View>
        </View>

        {/* PERSONAL DETAILS */}
        <Text className="text-[12px] text-[#999] mx-[15px] mt-[10px] mb-[5px]">Body Type</Text>
        <TouchableOpacity className="h-[45px] bg-[#FFF] rounded-[10px] px-[15px] border border-[#DDD] mx-[15px] mb-[10px] justify-center" onPress={() => openPicker('Body Type', BODY_TYPE_OPTIONS, 'bodyType')}>
          <Text className="text-[#333] text-[14px]">{bodyType}</Text>
        </TouchableOpacity>

        <Text className="text-[12px] text-[#999] mx-[15px] mt-[10px] mb-[5px]">Sexuality</Text>
        <TouchableOpacity className="h-[45px] bg-[#FFF] rounded-[10px] px-[15px] border border-[#DDD] mx-[15px] mb-[10px] justify-center" onPress={() => openPicker('Sexuality', SEXUALITY_OPTIONS, 'sexuality')}>
          <Text className="text-[#333] text-[14px]">{sexuality}</Text>
        </TouchableOpacity>

        <Text className="text-[12px] text-[#999] mx-[15px] mt-[10px] mb-[5px]">Education</Text>
        <TouchableOpacity className="h-[45px] bg-[#FFF] rounded-[10px] px-[15px] border border-[#DDD] mx-[15px] mb-[10px] justify-center" onPress={() => openPicker('Education', EDUCATION_OPTIONS, 'education')}>
          <Text className="text-[#333] text-[14px]">{education}</Text>
        </TouchableOpacity>

        <Text className="text-[12px] text-[#999] mx-[15px] mt-[10px] mb-[5px]">Favorite Music</Text>
        <TouchableOpacity className="h-[45px] bg-[#FFF] rounded-[10px] px-[15px] border border-[#DDD] mx-[15px] mb-[10px] justify-center" onPress={() => openPicker('Favorite Music', MUSIC_OPTIONS, 'music')}>
          <Text className="text-[#333] text-[14px]">{music}</Text>
        </TouchableOpacity>

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
    </View>
  );
};