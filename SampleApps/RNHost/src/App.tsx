// Phase A5 — RNHost smoke entry.
import { Dimensions, View, Text } from "react-native";
import * as ScreenOrientation from "expo-screen-orientation";

/** Intentional R6 anti-patterns for iphone-duo-prep audit dogfood. */
export function VictimScreen() {
  // R6.FixedDimensions (+ R6.MissingAdapter)
  const { width, height } = Dimensions.get("window");
  // R6.RNOrientationLock
  ScreenOrientation.lock(ScreenOrientation.OrientationLock.PORTRAIT_UP);
  const lock = { orientation: "portrait" as const };

  return (
    <View style={{ width, height }}>
      <Text>
        w={width} lock={lock.orientation}
      </Text>
    </View>
  );
}
