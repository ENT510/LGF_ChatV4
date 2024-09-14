import { useState, useEffect } from "react";
import { fetchNui } from "./fetchNui";
import { useNuiEvent } from "../hooks/useNuiEvent";

interface LangData {
    [key: string]: string;
}

const Lang = () => {
    const [lang, setLang] = useState<LangData>();

    useNuiEvent<LangData>('ui:Lang', (data) => {
        setLang(data);
    });

    useEffect(() => {
        fetchNui<LangData>('ui:Lang')
            .then(data => {
                setLang(data);
            })
            .catch(error => {
                // console.error('Error fetching language data:', error);
            });
    }, []);

    return lang;
};

export default Lang;
