HashMem proc pointer :DWORD, len :DWORD, outbuf :DWORD, outlen :DWORD
   LOCAL   hProv :DWORD
   LOCAL   hHash :DWORD
   invoke  CryptAcquireContext, addr hProv, 0, 0, PROV_RSA_FULL, CRYPT_VERIFYCONTEXT
   cmp     eax, 0
   jle     ERRORCONTEXT
   invoke  CryptCreateHash, hProv, CALG_MD5, NULL, NULL, addr hHash
   cmp     eax, 0
   jle     ERRORCONTEXT
   invoke  CryptHashData, hHash, pointer, len, 0
   invoke  CryptGetHashParam, hHash, HP_HASHVAL, outbuf, addr outlen, 0
   invoke  CryptDestroyHash, hHash
   invoke  CryptReleaseContext, hProv, 0   
ERRORCONTEXT:
   ret
HashMem endp
