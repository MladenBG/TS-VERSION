import React, { useState } from 'react';
import { View, Text, Image, TouchableOpacity, Alert, ActivityIndicator } from 'react-native';
import * as ImagePicker from 'expo-image-picker';
import * as ImageManipulator from 'expo-image-manipulator';

interface ImageGalleryProps {
  initialImages?: string[];
  isPublicView?: boolean;
}

export const ImageGallery = ({ initialImages = [], isPublicView = false }: ImageGalleryProps) => {
  const [images, setImages] = useState<string[]>(initialImages);
  const [currentPage, setCurrentPage] = useState(1);
  const [isUploading, setIsUploading] = useState(false);
  
  const ITEMS_PER_PAGE = isPublicView ? 6 : 5; 
  const totalPages = Math.ceil((isPublicView ? images.length : images.length + 1) / ITEMS_PER_PAGE) || 1;
  const startIndex = (currentPage - 1) * ITEMS_PER_PAGE;
  const currentImages = images.slice(startIndex, startIndex + ITEMS_PER_PAGE);

  const handleUploadPhoto = async () => {
    if (isPublicView) return;

    // 1. Ask for permission and open Gallery
    const permissionResult = await ImagePicker.requestMediaLibraryPermissionsAsync();
    
    if (permissionResult.granted === false) {
      Alert.alert("Permission Required", "You need to allow access to your photos to upload an image.");
      return;
    }

    const result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ['images'],
      allowsEditing: true,
      aspect: [4, 4], 
      quality: 1, 
    });

    if (!result.canceled && result.assets && result.assets.length > 0) {
      const originalUri = result.assets[0].uri;
      setIsUploading(true);

      try {
        // 2. Squash the Image and Convert to WebP! (Saves you massive amounts of Cloudflare data)
        const manipResult = await ImageManipulator.manipulateAsync(
          originalUri,
          [{ resize: { width: 800 } }], // Resize so it's not a massive 4K photo
          { compress: 0.7, format: ImageManipulator.SaveFormat.WEBP }
        );

        // 3. Ask your Node Server for the Cloudflare VIP Ticket
        // 🚨 IMPORTANT: If you test on a REAL PHONE, change 10.0.2.2 to your laptop's real Wi-Fi IP (like 192.168.1.15)
        const response = await fetch('http://10.0.2.2:3000/api/get-upload-url');
        const { uploadUrl, publicUrl } = await response.json();

        if (!uploadUrl) throw new Error("Did not receive upload URL from server");

        // 4. Turn the WebP file into a Blob to send over the internet
        const imageResponse = await fetch(manipResult.uri);
        const blob = await imageResponse.blob();

        // 5. BLAST IT TO CLOUDFLARE R2 🚀
        const uploadRes = await fetch(uploadUrl, {
          method: 'PUT',
          body: blob,
          headers: {
            'Content-Type': 'image/webp',
          },
        });

        if (uploadRes.ok) {
          // Success! Add the permanent Cloudflare link to your local state
          setImages(prev => [publicUrl, ...prev]);
          
          // 💡 NOTE FOR LATER: Right here is where you would do one more fetch() 
          // to tell your PostgreSQL database to save `publicUrl` to your user profile!
          
          Alert.alert("Success!", "Photo uploaded to Cloudflare R2!");
        } else {
          throw new Error("Cloudflare rejected the upload");
        }
      } catch (error) {
        console.error("Upload error:", error);
        Alert.alert("Upload Failed", "Something went wrong sending the photo to the cloud.");
      } finally {
        setIsUploading(false);
      }
    }
  };

  const handleImagePress = (index: number) => {
    if (isPublicView) {
      Alert.alert("Gallery", `Viewing image ${index + 1} in fullscreen (Coming soon!)`);
      return;
    }

    Alert.alert(
      "Manage Photo", 
      "Do you want to delete this photo from your profile?",
      [
        { text: "Cancel", style: "cancel" },
        { 
          text: "Delete", 
          style: "destructive", 
          onPress: () => {
            const actualIndex = startIndex + index;
            setImages(prev => prev.filter((_, i) => i !== actualIndex));
          } 
        }
      ]
    );
  };

  return (
    <View className="bg-white rounded-2xl shadow-sm border border-gray-100 p-4 mb-4">
      <Text className="text-xl font-black text-gray-800 mb-4">
        {isPublicView ? `📸 Gallery (${images.length})` : `📸 My Gallery (${images.length})`}
      </Text>
      
      <View className="flex-row flex-wrap justify-start gap-2 mb-2">
        
        {!isPublicView && currentPage === 1 && (
          <TouchableOpacity 
            onPress={handleUploadPhoto}
            disabled={isUploading}
            className="w-[31%] aspect-square rounded-xl overflow-hidden border-2 border-dashed border-green-400 bg-green-50 items-center justify-center"
          >
            {isUploading ? (
              <ActivityIndicator color="#4CAF50" size="large" />
            ) : (
              <>
                <Text className="text-3xl">➕</Text>
                <Text className="text-[10px] font-bold text-green-600 mt-1 uppercase tracking-wider">Upload</Text>
              </>
            )}
          </TouchableOpacity>
        )}

        {currentImages.map((imgUri, index) => (
          <TouchableOpacity 
            key={index}
            onPress={() => handleImagePress(index)}
            className="w-[31%] aspect-square rounded-xl overflow-hidden border border-gray-200 shadow-sm"
          >
            <Image source={{ uri: imgUri }} className="w-full h-full bg-gray-200" />
          </TouchableOpacity>
        ))}

        {isPublicView && images.length === 0 && (
          <Text className="text-gray-400 text-center py-4 font-bold w-full">This user hasn't uploaded any photos yet.</Text>
        )}
      </View>

      {images.length > (isPublicView ? ITEMS_PER_PAGE : ITEMS_PER_PAGE - 1) && (
        <View className="flex-row justify-between items-center mt-2 border-t border-gray-100 pt-3">
          <TouchableOpacity 
            onPress={() => setCurrentPage(prev => Math.max(prev - 1, 1))} 
            className={`p-2 rounded-lg min-w-[80px] items-center ${currentPage === 1 ? 'bg-gray-300' : 'bg-green-500'}`}
            disabled={currentPage === 1}
          >
            <Text className="text-white font-bold text-xs">Prev</Text>
          </TouchableOpacity>
          
          <Text className="text-gray-600 font-bold text-xs">
            {currentPage} / {totalPages}
          </Text>
          
          <TouchableOpacity 
            onPress={() => setCurrentPage(prev => Math.min(prev + 1, totalPages))} 
            className={`p-2 rounded-lg min-w-[80px] items-center ${currentPage === totalPages ? 'bg-gray-300' : 'bg-green-500'}`}
            disabled={currentPage === totalPages}
          >
            <Text className="text-white font-bold text-xs">Next</Text>
          </TouchableOpacity>
        </View>
      )}
    </View>
  );
};