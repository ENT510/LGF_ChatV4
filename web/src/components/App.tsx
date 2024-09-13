import React, { useEffect, useState } from 'react';
import { fetchNui } from '../utils/fetchNui';
import { useNuiEvent } from '../hooks/useNuiEvent';
import { debugData } from '../utils/debugData';
import { isEnvBrowser } from '../utils/misc';
import Chat from './Chat';
import './index.scss';

debugData([{ action: 'openChat', data: true },], 100);

const App: React.FC = () => {
  const [chatVisible, setChatVisible] = useState(false);
  const [chatId, setChatId] = useState<number | null>(null);

  useNuiEvent<{ visible: boolean; id: number }>('openChat', ({ visible, id }) => {
    setChatVisible(visible);
    setChatId(id); 
  });

  useEffect(() => {
    const keyHandler = (e: KeyboardEvent) => {
      if (chatVisible && e.code === 'Escape') {
        if (!isEnvBrowser()) {
          if (chatVisible) {
            fetchNui('ui:Close', { name: 'openChat' });
          }
        } else {
          setChatVisible(false);
        }
      }
    };

    window.addEventListener('keydown', keyHandler);

    return () => {
      window.removeEventListener('keydown', keyHandler);
    };
  }, [chatVisible]);

  return (
    <>
      <Chat visible={chatVisible} id={chatId} /> 
    </>
  );
};

export default App;
