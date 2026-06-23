---
title: 51单片机学习笔记教程
date: 2026-5-31 22:48:00
tags:
  - Arduino
  - 单片机
  - vibe coding
  - C
categories:
  - 博客
---



# Arduino UNO R3 红外遥控舵机按压墙壁开关实验笔记

## 1. 实验目标

使用 **Arduino UNO R3 + 红外接收头 + 舵机** 实现一个机械按压器，用来模拟人工按下墙壁上的塑料开关。

本实验不直接控制 220V 市电，不改动原来的墙壁开关线路，而是通过舵机摆臂物理按压开关。

整体结构：

```text
红外遥控器
    ↓
红外接收头
    ↓
Arduino UNO R3
    ↓
舵机
    ↓
机械按压塑料开关
```

---

## 2. 硬件清单

| 器件 | 数量 | 说明 |
|---|---:|---|
| Arduino UNO R3 | 1 | 主控板 |
| 红外接收头 | 1 | 常见 VS1838B / HX1838 / TSOP1838 |
| 红外遥控器 | 1 | 普通 38kHz 红外遥控器 |
| 舵机 | 1 | 推荐 MG90S，SG90 也可先测试 |
| 外部 5V 电源 | 1 | 建议 5V 1A 以上，不能只靠 Arduino 5V 给舵机供电 |
| 杜邦线 | 若干 | 接线 |
| 支架/热熔胶/3D打印件 | 若干 | 固定舵机，用于按压开关 |
| 470uF~1000uF 电解电容 | 可选 | 并在舵机电源两端，减小电源波动 |

---

## 3. 红外接收头接线

三脚红外接收头常见外观如下：

```text
正面看红外接收头，黑色接收窗口面对自己，引脚朝下：

        黑色接收窗口
       ┌─────────┐
       │         │
       └─────────┘
        |   |   |
        |   |   |
       OUT GND VCC
```

接线表：

| 红外接收头 | Arduino UNO R3 |
|---|---|
| OUT / DATA / S | D2 |
| GND / - | GND |
| VCC / + | 5V |

接线示意：

```text
红外接收头 OUT  → Arduino D2
红外接收头 GND  → Arduino GND
红外接收头 VCC  → Arduino 5V
```

注意：

```text
如果从背面看，引脚顺序会反过来。
常见 1838B 正面看通常是：OUT - GND - VCC。
如果你的型号不同，要以卖家资料或数据手册为准。
```

---

## 4. 舵机接线

舵机常见三根线：

| 舵机线颜色 | 功能 | 接法 |
|---|---|---|
| 红色 | 5V | 外部 5V 电源正极 |
| 棕色/黑色 | GND | 外部 5V 电源负极 |
| 黄色/橙色 | 信号线 | Arduino D9 |

必须共地：

```text
Arduino GND 必须连接到外部 5V 电源负极。
```

完整接线：

```text
舵机红线      → 外部 5V +
舵机棕/黑线   → 外部 5V -
舵机黄/橙线   → Arduino D9

Arduino GND  → 外部 5V -
```

推荐电源结构：

```text
外部 5V 电源正极  → 舵机红线
外部 5V 电源负极  → 舵机 GND
外部 5V 电源负极  → Arduino GND
Arduino D9        → 舵机信号线
```

不要直接用 Arduino 的 5V 给舵机供电。舵机启动或堵转时电流较大，可能导致 Arduino 重启。

---

## 5. 实验步骤总览

建议按下面顺序进行：

```text
第一步：确认红外接收头可以收到数据
第二步：单独测试舵机能否转动
第三步：调试舵机按压角度
第四步：红外按键控制舵机两个方向旋转
第五步：用 0x49 / 0x4A 永久设置旋转角度
第六步：安装机械结构，实际按压墙壁塑料开关
```

---

# 6. 实验一：读取红外遥控器键码

## 6.1 功能

通过 Arduino 串口监视器读取遥控器按键对应的 `Command` 值。

例如：

```text
按键 A → Command: 0x45
按键 B → Command: 0x46
按键 C → Command: 0x49
按键 D → Command: 0x4A
```

## 6.2 代码

需要先在 Arduino IDE 中安装库：

```text
工具 → 管理库 → 搜索 IRremote → 安装
```

代码如下：

```cpp
#include <IRremote.hpp>

#define IR_RECEIVE_PIN 2

void setup() {
  Serial.begin(9600);

  IrReceiver.begin(IR_RECEIVE_PIN, ENABLE_LED_FEEDBACK);

  Serial.println("IR receiver ready");
  Serial.println("Press a button on your remote...");
}

void loop() {
  if (IrReceiver.decode()) {
    Serial.print("Protocol: ");
    Serial.println(getProtocolString(IrReceiver.decodedIRData.protocol));

    Serial.print("Command: 0x");
    Serial.println(IrReceiver.decodedIRData.command, HEX);

    Serial.print("RawData: 0x");
    Serial.println(IrReceiver.decodedIRData.decodedRawData, HEX);

    Serial.println("----------------");

    IrReceiver.resume();
  }
}
```

## 6.3 观察结果

打开串口监视器，波特率设置为：

```text
9600
```

按遥控器按键，如果输出类似下面结果，说明红外接收成功：

```text
Command: 0x45
RawData: 0xBA45FF00
```

---

# 7. 实验二：单独测试舵机转动

## 7.1 功能

让舵机在几个角度之间循环转动，确认舵机接线和供电正常。

## 7.2 代码

```cpp
#include <Servo.h>

Servo myServo;

#define SERVO_PIN 9

void setup() {
  myServo.attach(SERVO_PIN);
}

void loop() {
  myServo.write(90);
  delay(1000);

  myServo.write(45);
  delay(1000);

  myServo.write(90);
  delay(1000);

  myServo.write(135);
  delay(1000);
}
```

## 7.3 正常现象

舵机应该按照下面顺序转动：

```text
90° → 45° → 90° → 135° → 循环
```

如果舵机不动，检查：

```text
1. 舵机红线是否接外部 5V
2. 舵机 GND 是否与 Arduino GND 共地
3. 舵机信号线是否接 D9
4. 外部 5V 电源电流是否足够
```

---

# 8. 实验三：串口调试舵机角度

## 8.1 功能

通过串口输入角度，让舵机转到指定位置，用于找出合适的按压角度。

## 8.2 代码

```cpp
#include <Servo.h>

Servo myServo;

#define SERVO_PIN 9

void setup() {
  Serial.begin(9600);

  myServo.attach(SERVO_PIN);
  myServo.write(90);

  Serial.println("Servo angle test ready.");
  Serial.println("Input angle 0~180, example: 90");
}

void loop() {
  if (Serial.available()) {
    int angle = Serial.parseInt();

    if (angle >= 0 && angle <= 180) {
      Serial.print("Servo angle = ");
      Serial.println(angle);

      myServo.write(angle);
    }
  }
}
```

## 8.3 调试方法

打开串口监视器，输入：

```text
90
45
30
120
135
```

找到两个关键角度：

```text
idleAngle：舵机不碰开关的位置
pressAngle：舵机能按下开关的位置
```

例如：

```cpp
int idleAngle = 90;
int pressAngle = 45;
```

如果方向反了，可以尝试：

```cpp
int idleAngle = 90;
int pressAngle = 135;
```

---

# 9. 实验四：0x45 和 0x46 控制相反方向旋转

## 9.1 功能

实现下面效果：

```text
按键 0x45 → 舵机向一个方向旋转
按键 0x46 → 舵机向相反方向旋转
两个方向旋转角度一致
```

以 90° 为中间位置，旋转角度为 45° 时：

```text
0x45：90° → 45° → 90°
0x46：90° → 135° → 90°
```

## 9.2 代码

```cpp
#include <IRremote.hpp>
#include <Servo.h>

#define IR_RECEIVE_PIN 2
#define SERVO_PIN 9

Servo myServo;

// 舵机中间位置
int idleAngle = 90;

// 旋转幅度
// 0x45: idleAngle - rotateOffset
// 0x46: idleAngle + rotateOffset
int rotateOffset = 45;

// 按压保持时间
const int pressHoldTime = 400;

// 回到中间后的等待时间
const int returnWaitTime = 300;

// 红外按键码
const uint16_t KEY_LEFT  = 0x45;
const uint16_t KEY_RIGHT = 0x46;

void servoMoveTo(int targetAngle) {
  if (targetAngle < 0) {
    targetAngle = 0;
  }

  if (targetAngle > 180) {
    targetAngle = 180;
  }

  myServo.attach(SERVO_PIN);
  delay(50);

  myServo.write(idleAngle);
  delay(100);

  myServo.write(targetAngle);
  delay(pressHoldTime);

  myServo.write(idleAngle);
  delay(returnWaitTime);

  myServo.detach();
}

void setup() {
  Serial.begin(9600);

  myServo.attach(SERVO_PIN);
  myServo.write(idleAngle);
  delay(500);
  myServo.detach();

  IrReceiver.begin(IR_RECEIVE_PIN, ENABLE_LED_FEEDBACK);

  Serial.println("IR servo controller ready.");
  Serial.println("0x45 -> one direction");
  Serial.println("0x46 -> opposite direction");
}

void loop() {
  if (IrReceiver.decode()) {

    if (!(IrReceiver.decodedIRData.flags & IRDATA_FLAGS_IS_REPEAT)) {

      uint16_t cmd = IrReceiver.decodedIRData.command;

      Serial.print("Command: 0x");
      Serial.println(cmd, HEX);

      if (cmd == KEY_LEFT) {
        Serial.println("Move left direction");

        int targetAngle = idleAngle - rotateOffset;
        servoMoveTo(targetAngle);
      }

      else if (cmd == KEY_RIGHT) {
        Serial.println("Move right direction");

        int targetAngle = idleAngle + rotateOffset;
        servoMoveTo(targetAngle);
      }
    }

    IrReceiver.resume();
  }
}
```

---

# 10. 实验五：使用 0x49 和 0x4A 永久修改旋转角度

## 10.1 功能

通过遥控器按键设置旋转角度，并保存到 Arduino UNO 的 EEPROM 中。

按键功能：

| 按键码 | 功能 |
|---|---|
| 0x45 | 向一个方向旋转 |
| 0x46 | 向相反方向旋转 |
| 0x49 | 永久设置旋转角度为 30° |
| 0x4A | 永久设置旋转角度为 60° |

效果：

```text
如果当前角度是 30°：

0x45：90° → 60° → 90°
0x46：90° → 120° → 90°

如果当前角度是 60°：

0x45：90° → 30° → 90°
0x46：90° → 150° → 90°
```

## 10.2 完整代码

```cpp
#include <IRremote.hpp>
#include <Servo.h>
#include <EEPROM.h>

#define IR_RECEIVE_PIN 2
#define SERVO_PIN 9

Servo myServo;

// 舵机中间位置
int idleAngle = 90;

// 当前旋转角度，启动时会从 EEPROM 读取
int rotateOffset = 30;

// 红外按键码
const uint16_t KEY_LEFT  = 0x45;
const uint16_t KEY_RIGHT = 0x46;

const uint16_t KEY_SET_30 = 0x49;
const uint16_t KEY_SET_60 = 0x4A;

// EEPROM 存储地址
const int EEPROM_ADDR_ANGLE = 0;
const int EEPROM_ADDR_MAGIC = 1;

// 用于判断 EEPROM 中是否已经存过有效数据
const byte EEPROM_MAGIC_VALUE = 0xA5;

// 按压保持时间
const int pressHoldTime = 400;

// 回到中间后的等待时间
const int returnWaitTime = 300;

void saveAngleToEEPROM(int angle) {
  // 只允许保存 30 或 60
  if (angle != 30 && angle != 60) {
    return;
  }

  // 只有数据变化时才写 EEPROM，减少 EEPROM 写入次数
  if (EEPROM.read(EEPROM_ADDR_ANGLE) != angle) {
    EEPROM.update(EEPROM_ADDR_ANGLE, angle);
  }

  if (EEPROM.read(EEPROM_ADDR_MAGIC) != EEPROM_MAGIC_VALUE) {
    EEPROM.update(EEPROM_ADDR_MAGIC, EEPROM_MAGIC_VALUE);
  }

  Serial.print("Angle saved permanently: ");
  Serial.println(angle);
}

void loadAngleFromEEPROM() {
  byte magic = EEPROM.read(EEPROM_ADDR_MAGIC);
  byte savedAngle = EEPROM.read(EEPROM_ADDR_ANGLE);

  if (magic == EEPROM_MAGIC_VALUE && (savedAngle == 30 || savedAngle == 60)) {
    rotateOffset = savedAngle;
  } else {
    rotateOffset = 30;
    saveAngleToEEPROM(rotateOffset);
  }

  Serial.print("Current rotate offset: ");
  Serial.println(rotateOffset);
}

int limitAngle(int angle) {
  if (angle < 0) {
    angle = 0;
  }

  if (angle > 180) {
    angle = 180;
  }

  return angle;
}

void servoMoveTo(int targetAngle) {
  targetAngle = limitAngle(targetAngle);

  myServo.attach(SERVO_PIN);
  delay(50);

  myServo.write(idleAngle);
  delay(100);

  myServo.write(targetAngle);
  delay(pressHoldTime);

  myServo.write(idleAngle);
  delay(returnWaitTime);

  myServo.detach();
}

void handleIRCommand(uint16_t cmd) {
  Serial.print("Command: 0x");
  Serial.println(cmd, HEX);

  if (cmd == KEY_LEFT) {
    Serial.println("Move direction 1");

    int targetAngle = idleAngle - rotateOffset;
    servoMoveTo(targetAngle);
  }

  else if (cmd == KEY_RIGHT) {
    Serial.println("Move direction 2");

    int targetAngle = idleAngle + rotateOffset;
    servoMoveTo(targetAngle);
  }

  else if (cmd == KEY_SET_30) {
    rotateOffset = 30;
    saveAngleToEEPROM(rotateOffset);

    Serial.println("Rotate angle set to 30 degrees");
  }

  else if (cmd == KEY_SET_60) {
    rotateOffset = 60;
    saveAngleToEEPROM(rotateOffset);

    Serial.println("Rotate angle set to 60 degrees");
  }

  else {
    Serial.println("Unknown key");
  }
}

void setup() {
  Serial.begin(9600);

  loadAngleFromEEPROM();

  myServo.attach(SERVO_PIN);
  myServo.write(idleAngle);
  delay(500);
  myServo.detach();

  IrReceiver.begin(IR_RECEIVE_PIN, ENABLE_LED_FEEDBACK);

  Serial.println("IR servo controller ready.");
  Serial.println("0x45 -> rotate one direction");
  Serial.println("0x46 -> rotate opposite direction");
  Serial.println("0x49 -> set angle to 30 permanently");
  Serial.println("0x4A -> set angle to 60 permanently");
}

void loop() {
  if (IrReceiver.decode()) {

    if (!(IrReceiver.decodedIRData.flags & IRDATA_FLAGS_IS_REPEAT)) {
      uint16_t cmd = IrReceiver.decodedIRData.command;
      handleIRCommand(cmd);
    }

    IrReceiver.resume();
  }
}
```

---

## 10.3 EEPROM 永久保存说明

使用 EEPROM 保存旋转角度后，即使 Arduino 断电重启，设置也不会丢失。

关键写入语句：

```cpp
EEPROM.update(EEPROM_ADDR_ANGLE, angle);
```

关键读取语句：

```cpp
byte savedAngle = EEPROM.read(EEPROM_ADDR_ANGLE);
```

使用 `EEPROM.update()` 的好处：

```text
只有当数据发生变化时才真正写入 EEPROM，可以减少 EEPROM 写入次数。
```

---

# 11. 实际安装机械结构

## 11.1 舵机动作逻辑

舵机动作应该是：

```text
原位，不碰开关
    ↓
转动，压下塑料开关
    ↓
保持 0.4 秒
    ↓
回到原位
```

## 11.2 角度调整建议

如果按不下去，可以增大旋转角度：

```cpp
rotateOffset = 60;
```

如果动作太大，可以改小旋转角度：

```cpp
rotateOffset = 30;
```

如果方向反了，可以交换 0x45 和 0x46 的目标角度：

```cpp
if (cmd == KEY_LEFT) {
  int targetAngle = idleAngle + rotateOffset;
  servoMoveTo(targetAngle);
}

else if (cmd == KEY_RIGHT) {
  int targetAngle = idleAngle - rotateOffset;
  servoMoveTo(targetAngle);
}
```

---

# 12. 常见问题

## 12.1 红外能收到数据，但舵机不动

检查：

```text
1. 舵机信号线是否接 D9
2. 舵机是否使用外部 5V 供电
3. Arduino GND 是否和舵机电源 GND 共地
4. 程序中的按键码是否和串口输出一致
```

## 12.2 舵机一动 Arduino 就重启

大概率是舵机电流太大，电源不稳。

解决：

```text
1. 舵机单独使用外部 5V 电源
2. Arduino 和舵机必须共地
3. 舵机电源两端并 470uF~1000uF 电容
```

## 12.3 舵机一直抖动或发热

解决：

```text
1. 按完后回到 idleAngle
2. 使用 myServo.detach() 断开控制信号
3. 不要让舵机长时间顶住塑料开关
```

## 12.4 按 0x49 或 0x4A 后，断电重启仍然没有保存

检查：

```text
1. 串口是否显示 Angle saved permanently
2. 是否使用 EEPROM.update()
3. 是否按键码写错，例如 0x4A 写成 0x4a 是允许的，但 0x4B 就不对
```

---

# 13. 当前最终功能总结

当前最终代码实现了：

```text
0x45：以当前保存的角度向一个方向旋转
0x46：以当前保存的角度向相反方向旋转
0x49：设置旋转角度为 30°，并永久保存
0x4A：设置旋转角度为 60°，并永久保存
```

启动时会自动从 EEPROM 读取上次保存的旋转角度。

默认角度为：

```cpp
rotateOffset = 30;
```

---

# 14. 下一步扩展

当前是一个舵机控制一个开关。

如果要扩展为三路三开开关，可以改成：

```text
舵机1信号线 → Arduino D9
舵机2信号线 → Arduino D10
舵机3信号线 → Arduino D11
```

然后把：

```cpp
Servo myServo;
```

扩展为：

```cpp
Servo servo1;
Servo servo2;
Servo servo3;
```

或者使用数组：

```cpp
Servo servos[3];
```

红外按键可以规划为：

```text
0x45 / 0x46：控制第 1 路开关
0x47 / 0x44：控制第 2 路开关
0x40 / 0x43：控制第 3 路开关
0x49：设置角度为 30°
0x4A：设置角度为 60°
```
