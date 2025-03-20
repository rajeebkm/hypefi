import Image from "next/image";
import Navbar from "./common/Navbar";
import Socials from "./common/Socials";
import { contentPagesList, routerItemsList } from "~~/constants/routes";

function Footer() {
  return (
    <section className="py-5 sm:py-20 px-5 sm:px-40 mt-5 border-white-12 border-t flex flex-col items-center justify-center gap-10">
      <Image src="/HYPEFI.png" width={100} height={100} alt="HypeFi logo" className="footer-logo" />
      <Navbar navItems={[...routerItemsList, ...contentPagesList]} />
      <div className="w-full border-b-1 border-b border-white "></div>
      <div className="flex justify-between w-full">
        <p className="text-xs text-gray-500">© 2025-2026 HypeFi™. All rights reserved</p>
        <Socials 
          discord="https://discord.com/" 
          x="https://x.com/" 
          telegram="https://x.com/" 
          className="!gap-2" 
        />
      </div>
    </section>
  );
}

export default Footer;
