import React, { useState, useEffect, useRef } from "react";
import {
  Avatar,
  TextInput,
  Button,
  Paper,
  ScrollArea,
  Group,
  Text,
  Badge,
  ActionIcon,
  Flex,
  Tooltip,
  ColorPicker,
  NumberInput,
  Loader,
  Transition,
  Switch,
  Slider,
} from "@mantine/core";
import {
  IconTrash,
  IconMoodSmile,
  IconAt,
  IconHandMove,
  IconMessage,
  IconMaximize,
  IconPalette,
  IconAlertCircle,
  IconVolume,
  IconBell,
  IconSettings,
} from "@tabler/icons-react";
import Picker, { EmojiClickData, Theme } from "emoji-picker-react";
import newMessageSound from "./newmessage.wav";
import { fetchNui } from "../utils/fetchNui";
import defaultAvatar from "../img/fallback.png";
import systemAvatar from "../img/system.png";

interface ChatProps {
  visible: boolean;
  id: number | null;
}

interface Message {
  user: string;
  message: string;
  time: string;
  isMine: boolean;
  job?: string;
  isSystemMessage?: boolean;
  id?: string;
  avatar?: string;
}

interface Config {
  EnableGroupMessage: boolean;
}

const DEFAULT_AVATAR = defaultAvatar;
const SYSTEM_MESSAGE_AVATAR = systemAvatar;

const Chat: React.FC<ChatProps> = ({ visible, id }) => {
  const [messages, setMessages] = useState<Message[]>([]);
  const [newMessage, setNewMessage] = useState("");
  const [showEmojiPicker, setShowEmojiPicker] = useState(false);
  const [settingsMenuVisible, setSettingsMenuVisible] = useState(false);
  const [textSize, setTextSize] = useState(14);
  const [chatColor, setChatColor] = useState("#252525fa");
  const [darkMode, setDarkMode] = useState(false);
  const [notificationList, setNotificationList] = useState<{
    id: number;
    author: string;
  }[]>([]);
  const [notificationSoundEnabled, setNotificationSoundEnabled] =
    useState(false);
  const [notificationVolume, setNotificationVolume] = useState(1);
  const [notificationsEnabled, setNotificationsEnabled] = useState(true);
  const [isVisible, setIsVisible] = useState(visible);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLInputElement>(null);
  const scrollContainerRef = useRef<HTMLDivElement>(null);
  const soundRef = useRef<HTMLAudioElement>(new Audio(newMessageSound));
  const [config, setConfig] = useState<Config>({ EnableGroupMessage: true });

  useEffect(() => {
    soundRef.current.volume = notificationVolume;
  }, [notificationVolume]);

  useEffect(() => {
    const handleMessage = (event: MessageEvent) => {
      const data = event.data;
      if (data.action === "addSendMessage") {
        if (data.data) {
          const {
            message = "",
            author = "System",
            playerJob = "",
            isSystemMessage = false,
            avatar = "",
            id: senderId = "",
          } = data.data;
          const now = new Date();
          const currentTime = now.toLocaleTimeString([], {
            hour: "2-digit",
            minute: "2-digit",
          });

          const isMine = String(senderId) === String(id);

          setMessages((prevMessages) => [
            ...prevMessages,
            {
              user: author,
              message,
              time: currentTime,
              isMine: isMine,
              job: isSystemMessage ? "" : playerJob,
              isSystemMessage,
              avatar: !isSystemMessage && avatar ? avatar : "",
              id: senderId,
            },
          ]);

          if (!isVisible) {
            const newNotificationId = Date.now();
            setNotificationList((prevList) => [
              ...prevList,
              { id: newNotificationId, author },
            ]);

            if (notificationSoundEnabled) {
              soundRef.current.play();
            }

            setTimeout(() => {
              setNotificationList((prevList) =>
                prevList.filter(
                  (notification) => notification.id !== newNotificationId
                )
              );
            }, 5000);
          }
        } else {
          console.error("Received data is undefined or malformed:", data);
        }
      }
    };

    window.addEventListener("message", handleMessage);

    return () => {
      window.removeEventListener("message", handleMessage);
    };
  }, [notificationSoundEnabled, notificationVolume, id, isVisible]);

  useEffect(() => {
    if (visible) {
      setIsVisible(true);
      inputRef.current?.focus();
    } else {
      closeChat();
    }
  }, [visible]);

  useEffect(() => {
    const fetchConfig = async () => {
      try {
        const response = await fetchNui<Config>("LGF_Chat_V4.GetConfig");
        setConfig(response);
      } catch (error) {
        console.error("Failed to fetch configuration:", error);
      }
    };

    if (isVisible) {
      fetchConfig();
    }
  }, [isVisible]);

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const closeChat = () => {
    setIsVisible(false);
    setShowEmojiPicker(false);
    setSettingsMenuVisible(false);
    setNewMessage("");
  };

  const onEmojiClick = (emojiData: EmojiClickData) => {
    setNewMessage((prevMessage) => prevMessage + emojiData.emoji);
  };

  const sendMessage = async () => {
    if (newMessage.trim()) {
      const now = new Date();
      const currentTime = now.toLocaleTimeString([], {
        hour: "2-digit",
        minute: "2-digit",
      });

      const messageData = {
        message: newMessage,
        time: currentTime,
      };

      try {
        await fetchNui("sendMessage", messageData);
        setNewMessage("");
      } catch (error) {
        console.error("Failed to send message:", error);
      }
    }
  };

  const sendSystemMessage = async (message: string) => {
    const now = new Date();
    const currentTime = now.toLocaleTimeString([], {
      hour: "2-digit",
      minute: "2-digit",
    });

    const systemMessageData = {
      user: "System",
      message,
      time: currentTime,
      isSystemMessage: true,
    };
    try {
      await fetchNui("sendSystemMessage", systemMessageData);
    } catch (error) {
      console.error("Failed to send system message:", error);
    }
  };

  const resetChatColor = () => {
    setChatColor("#252525fa");
  };

  const clearChat = () => {
    setMessages([]);
    sendSystemMessage("Chat has been cleared.");
  };

  const handleTextSizeChange = (value: number) => {
    setTextSize(value);
  };

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  };

  return (
    <div className={`chat-wrapper ${darkMode ? "dark-mode" : ""}`}>
      <div
        className={`chat-container ${isVisible ? "show" : ""}`}
        style={{ backgroundColor: chatColor }}
      >
        <div className="chat-header">
          <h2>LGF CHAT</h2>
          <Tooltip label="Reset Chat Color" position="right" withArrow>
            <ActionIcon variant="light" color="blue" onClick={resetChatColor}>
              <IconPalette size={18} />
            </ActionIcon>
          </Tooltip>
        </div>

        <ScrollArea
          h={310}
          scrollbarSize={0}
          offsetScrollbars
          ref={scrollContainerRef}
        >
          <div className="messages">
            {messages.map((msg, index) => (
              <Group
                key={index}
                position={msg.isSystemMessage || !msg.isMine ? "left" : "right"}
                mt="xs"
                style={{
                  justifyContent:
                    msg.isSystemMessage || !msg.isMine
                      ? "flex-start"
                      : "flex-end",
                }}
              >
                <Avatar
                  radius="lg"
                  size="md"
                  src={
                    msg.isSystemMessage
                      ? SYSTEM_MESSAGE_AVATAR
                      : msg.avatar || DEFAULT_AVATAR
                  }
                  alt={msg.user}
                />
                <Paper
                  shadow="md"
                  radius="md"
                  p="md"
                  className={`chat-message-content ${msg.isMine ? "mine" : ""}`}
                  style={{
                    fontSize: `${textSize}px`,
                    color: "#ffffff",
                    maxWidth: "73%",
                    paddingLeft: "10px",
                    wordBreak: "break-word",
                    display: "flex",
                    flexDirection: "column",
                    position: "relative",
                    fontFamily: "'Roboto', sans-serif",
                    backgroundColor: "#1A1B1E",
                  }}
                >
                  <Flex direction="column" style={{ width: "100%" }}>
                    <Flex
                      justify="space-between"
                      align="flex-start"
                      mb="xs"
                      style={{
                        marginBottom: "5px",
                        flexWrap: "wrap",
                      }}
                    >
                      <Group spacing="xs">
                        <Badge
                          size="sm"
                          radius="sm"
                          color={msg.isMine ? "blue" : "green"}
                          style={{ marginBottom: "5px" }}
                        >
                          {msg.user}
                        </Badge>
                        {!msg.isSystemMessage &&
                          msg.job &&
                          config.EnableGroupMessage && (
                            <Badge
                              style={{ marginBottom: "5px" }}
                              size="sm"
                              radius="sm"
                              color="orange"
                            >
                              {msg.job}
                            </Badge>
                          )}
                        {!msg.isSystemMessage && msg.id && (
                          <Badge
                            style={{ marginBottom: "5px" }}
                            size="sm"
                            radius="sm"
                            color="orange"
                          >
                            ID : {msg.id}
                          </Badge>
                        )}
                        <Badge
                          style={{ marginBottom: "5px" }}
                          size="sm"
                          radius="sm"
                          color="violet"
                        >
                          {msg.time}
                        </Badge>
                      </Group>
                    </Flex>
                    {msg.isSystemMessage ? (
                      <Text
                        size="sm"
                        style={{
                          fontSize: `${textSize}px`,
                          fontStyle: "italic",
                          color: "#aaa",
                        }}
                      >
                        {msg.message}
                      </Text>
                    ) : (
                      <Text
                        size="sm"
                        style={{
                          fontSize: `${textSize}px`,
                          paddingLeft: "8px",
                          fontStyle: "italic",
                          color: "#aaa",
                        }}
                      >
                        {msg.message}
                      </Text>
                    )}
                  </Flex>
                </Paper>
              </Group>
            ))}
            <div ref={messagesEndRef} />
          </div>
        </ScrollArea>

        <div className="input-container">
          <Flex mih={45} justify="flex-end" align="flex-end" wrap="nowrap">
            <TextInput
              placeholder="Type your message..."
              value={newMessage}
              icon={<IconAt size={20} />}
              onChange={(e) => setNewMessage(e.currentTarget.value)}
              onKeyDown={(e) => e.key === "Enter" && sendMessage()}
              style={{ flex: 1, marginRight: "10px" }}
              rightSection={
                <Tooltip label="This is public" position="top-end" withArrow>
                  <div>
                    <IconAlertCircle
                      size="1rem"
                      style={{ display: "block", opacity: 0.5 }}
                    />
                  </div>
                </Tooltip>
              }
              ref={inputRef}
            />
            <Button
              leftIcon={<IconMessage size={19} />}
              variant="light"
              color="violet"
              onClick={sendMessage}
            >
              Send
            </Button>

            <Tooltip label="Add emoji" position="top" withArrow>
              <ActionIcon
                variant="light"
                color="blue"
                onClick={() => setShowEmojiPicker(!showEmojiPicker)}
                style={{ marginLeft: "11px" }}
              >
                <IconMoodSmile size={24} />
              </ActionIcon>
            </Tooltip>

            <Tooltip label="Clear chat" position="top" withArrow>
              <ActionIcon
                variant="light"
                color="red"
                onClick={clearChat}
                style={{ marginLeft: "11px" }}
              >
                <IconTrash size={24} />
              </ActionIcon>
            </Tooltip>

            <Tooltip label="Scroll to bottom" position="top" withArrow>
              <ActionIcon
                variant="light"
                color="teal"
                onClick={scrollToBottom}
                style={{ marginLeft: "11px" }}
              >
                <IconHandMove size={24} />
              </ActionIcon>
            </Tooltip>
            <Tooltip label="Settings Menu" position="top" withArrow>
              <ActionIcon
                variant="light"
                color="orange"
                onClick={() => setSettingsMenuVisible(!settingsMenuVisible)}
                style={{ marginLeft: "11px" }}
              >
                <IconSettings size={24} />
              </ActionIcon>
            </Tooltip>
          </Flex>
        </div>
      </div>

      {showEmojiPicker && (
        <div className="emoji-picker">
          <Picker onEmojiClick={onEmojiClick} theme={Theme.DARK} />
        </div>
      )}

      <Transition
        mounted={settingsMenuVisible}
        transition="fade"
        duration={400}
        timingFunction="ease"
      >
        {(styles) => (
          <div
            className="settings-menu"
            style={{
              ...styles,
              padding: "10px",
              borderRadius: "12px",
              width: "220px",
              height: "380px",
            }}
          >
            <Flex direction="column" style={{ gap: "10px" }}>
              <Flex align="center">
                <IconPalette size={16} style={{ marginRight: "5px" }} />
                <Text>Background Color</Text>
              </Flex>
              <Flex align="center">
                <ColorPicker
                  color={chatColor}
                  onChange={(color) => {
                    setChatColor(color);
                  }}
                />
              </Flex>

              <NumberInput
                value={textSize}
                label="Size Text"
                onChange={(value) =>
                  handleTextSizeChange(value !== "" ? value : 14)
                }
                min={10}
                max={30}
                step={1}
                icon={<IconMaximize size={18} />}
                style={{ marginBottom: "10px" }}
              />

              <Flex align="center">
                <IconAlertCircle size={16} style={{ marginRight: "5px" }} />
                <Text>Notification Sound</Text>
                <Switch
                  checked={notificationSoundEnabled}
                  onChange={() => setNotificationSoundEnabled((prev) => !prev)}
                  style={{ marginLeft: "10px" }}
                />
              </Flex>

              {notificationSoundEnabled && (
                <Flex align="center" style={{ marginTop: "10px" }}>
                  <IconVolume size={16} style={{ marginRight: "5px" }} />
                  <Text>Volume</Text>
                  <Slider
                    value={notificationVolume * 100}
                    onChange={(value) => setNotificationVolume(value / 100)}
                    min={0}
                    max={100}
                    showLabelOnHover={false}
                    size="sm"
                    step={1}
                    style={{ width: "150px", marginLeft: "10px" }}
                  />
                </Flex>
              )}

              <Flex align="center">
                <IconBell size={16} style={{ marginRight: "5px" }} />
                <Text>Show Notifications</Text>
                <Switch
                  checked={notificationsEnabled}
                  onChange={() => setNotificationsEnabled((prev) => !prev)}
                  style={{ marginLeft: "10px" }}
                />
              </Flex>
            </Flex>
          </div>
        )}
      </Transition>

      {notificationsEnabled &&
        notificationList.map((notification) => (
          <div key={notification.id} className="notification">
            <div className="icon">
              <IconBell size={24} />
            </div>
            <Text className="notification-text">
              New message from {notification.author}
            </Text>
          </div>
        ))}
    </div>
  );
};

export default Chat;
