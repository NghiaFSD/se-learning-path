"use client";

import styles from "./checkout.module.scss";

import { useState } from "react";
import useSWR from "swr";
import { fetcher } from "@/utils/client";

const _PROVINCE_API = `http://localhost:3000/api/provinces`;
const _DISTRICT_API = `http://localhost:3000/api/district`;
const _INIT_FALLBACK_DATA = {
  data: [],
};

const Province = () => {
  // console.log(process.env.SERVER_API);
  const [provinceId, setProvinceId] = useState(0);
  const { data: provinces } = useSWR(
    { url: _PROVINCE_API, token: "123" },
    fetcher,
    {
      fallbackData: _INIT_FALLBACK_DATA,
      // dedupingInterval: 0,
    },
  );
  const { data: districts } = useSWR(
    {
      url: `${_DISTRICT_API}?province_id=${provinceId}`,
      token: "ahihi",
    },
    fetcher,
    {
      fallbackData: _INIT_FALLBACK_DATA,
    },
  );
  const handleChangeProvince = (e) => {
    setProvinceId(e.target.value);
  };
  return (
    <div>
      <select className={styles.select} onChange={handleChangeProvince}>
        <option value="">Chọn Tỉnh/TP</option>
        {provinces.data.map(({ code, name }) => (
          <option value={code} key={code}>
            {name}
          </option>
        ))}
      </select>
      <select className={styles.select}>
        <option value="">Chọn Quận/Huyện</option>
        {districts.data.map(({ code, name }) => (
          <option value={code} key={code}>
            {name}
          </option>
        ))}
      </select>
    </div>
  );
};

export default Province;
