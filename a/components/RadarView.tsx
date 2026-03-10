import React, { useEffect, useState } from 'react';
import { View, StyleSheet, Text, Image, TouchableOpacity, Alert, ActivityIndicator } from 'react-native';
import Animated, { 
  useSharedValue, 
  useAnimatedStyle, 
  withRepeat, 
  withTiming, 
  interpolate,
} from 'react-native-reanimated';
import * as Location from 'expo-location';

// 🚨 MATCH YOUR API URL
const API_URL = "http://10.0.2.2:3000"; 

const PulseCircle = ({ delay = 0 }: { delay?: number }) => {
  const pulse = useSharedValue(0);

  useEffect(() => {
    pulse.value = withRepeat(
      withTiming(1, { duration: 2000 }), 
      -1, 
      false
    );
  }, []);

  const animatedStyle = useAnimatedStyle(() => {
    return {
      opacity: interpolate(pulse.value, [0, 0.5, 1], [0.6, 0.3, 0]),
      transform: [{ scale: interpolate(pulse.value, [0, 1], [1, 4]) }]
    };
  });

  return <Animated.View style={[styles.pulse, animatedStyle]} />;
};

export default function RadarView({ currentUserId = "my_test_id" }: { currentUserId?: string }) {
  const [nearbyUsers, setNearbyUsers] = useState<any[]>([]);
  const [isSearching, setIsSearching] = useState(true);

  useEffect(() => {
    const fetchRadarData = async () => {
      setIsSearching(true);
      try {
        // 1. Ask for GPS Permission
        let { status } = await Location.requestForegroundPermissionsAsync();
        if (status !== 'granted') {
          Alert.alert('Permission Denied', 'Please allow location access to see nearby users.');
          setIsSearching(false);
          return;
        }

        // 2. Get exact Latitude and Longitude
        let location = await Location.getCurrentPositionAsync({
          accuracy: Location.Accuracy.Balanced,
        });
        const { latitude, longitude } = location.coords;

        // 3. Send location to backend and get nearby users
        const res = await fetch(`${API_URL}/api/users/radar`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ userId: currentUserId, latitude, longitude })
        });

        if (res.ok) {
          const data = await res.json();
          setNearbyUsers(data);
        } else {
          console.error("Failed to fetch radar users");
        }
      } catch (error) {
        console.error("Location Error:", error);
      } finally {
        setIsSearching(false);
      }
    };

    fetchRadarData();
  }, [currentUserId]);

  return (
    <View style={styles.container}>
      {/* Background Pulse Animations */}
      <PulseCircle />
      <PulseCircle delay={1000} />
      
      {/* Center User Icon (You) */}
      <View style={styles.centerDot}>
        <Text style={{ fontSize: 30 }}>📍</Text>
      </View>

      {/* 🚀 MAP OVER NEARBY USERS AND PLACE THEM ON THE RADAR 🚀 */}
      {nearbyUsers.map((user, index) => {
        // We limit max distance to 100km, max radius on screen is ~150 pixels
        const maxRadarRadius = 140; 
        const maxDistanceKm = 100;
        
        // Calculate how far from the center the user should be drawn
        const pixelDistanceFromCenter = (user.distance_km / maxDistanceKm) * maxRadarRadius;
        
        // Give them a random angle so they spread out in a circle
        const randomAngle = Math.random() * 2 * Math.PI; 

        // Calculate exact X and Y coordinates relative to the center
        const top = Math.sin(randomAngle) * pixelDistanceFromCenter;
        const left = Math.cos(randomAngle) * pixelDistanceFromCenter;

        return (
          <TouchableOpacity
            key={user.id}
            style={[styles.userBlip, { transform: [{ translateX: left }, { translateY: top }] }]}
            onPress={() => Alert.alert("Match Found!", `${user.name} is ${Math.round(user.distance_km)} km away from you!`)}
          >
            <Image 
              source={{ uri: user.image || 'https://picsum.photos/100' }} 
              style={styles.userImage} 
            />
            <View style={styles.distanceBadge}>
              <Text style={styles.distanceText}>{Math.round(user.distance_km)}km</Text>
            </View>
          </TouchableOpacity>
        );
      })}

      <Text style={styles.statusText}>
        {isSearching ? "Acquiring GPS Signal..." : `Found ${nearbyUsers.length} nearby matches`}
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: '#fff' },
  pulse: {
    position: 'absolute',
    width: 100,
    height: 100,
    borderRadius: 50,
    borderWidth: 2,
    borderColor: '#F43F5E',
  },
  centerDot: {
    width: 60,
    height: 60,
    borderRadius: 30,
    backgroundColor: '#333',
    justifyContent: 'center',
    alignItems: 'center',
    zIndex: 10,
    position: 'absolute'
  },
  statusText: { 
    position: 'absolute',
    bottom: 50,
    color: '#888', 
    fontWeight: 'bold',
    fontSize: 16
  },
  userBlip: {
    position: 'absolute',
    alignItems: 'center',
    justifyContent: 'center',
    zIndex: 20,
  },
  userImage: {
    width: 46,
    height: 46,
    borderRadius: 23,
    borderWidth: 3,
    borderColor: '#F43F5E',
    backgroundColor: '#ddd'
  },
  distanceBadge: {
    position: 'absolute',
    bottom: -10,
    backgroundColor: '#1F2937',
    paddingHorizontal: 6,
    paddingVertical: 2,
    borderRadius: 10,
    borderWidth: 1,
    borderColor: '#fff'
  },
  distanceText: {
    color: '#fff',
    fontSize: 9,
    fontWeight: '900'
  }
});