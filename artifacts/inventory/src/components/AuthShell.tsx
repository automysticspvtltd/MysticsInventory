import { useState, useEffect, type ReactNode } from "react";
import { Boxes } from "lucide-react";

function useCachedOrgLogo(): string | null {
  const [src, setSrc] = useState<string | null>(() => {
    try { return localStorage.getItem("__erp_org_logo_src"); } catch { return null; }
  });

  useEffect(() => {
    const stored = (() => {
      try { return localStorage.getItem("__erp_org_logo_src"); } catch { return null; }
    })();
    setSrc(stored);
  }, []);

  return src;
}

export function AuthShell({
  children,
  rightFooter,
}: {
  children: ReactNode;
  rightFooter?: ReactNode;
}) {
  const cachedLogo = useCachedOrgLogo();
  const [logoError, setLogoError] = useState(false);
  const showLogo = cachedLogo && !logoError;

  return (
    <div className="min-h-[100dvh] flex flex-col items-center justify-center bg-[#fafafa] px-4 py-10">
      <div className="w-full max-w-[350px] flex flex-col gap-3">
        {/* Main card */}
        <div className="bg-white border border-[#dbdbdb] rounded-sm px-10 pt-10 pb-8 flex flex-col items-center">
          {/* Brand */}
          <div className="flex flex-col items-center mb-8 select-none">
            <div className="h-14 w-14 rounded-2xl shadow-md mb-3 overflow-hidden flex items-center justify-center bg-gradient-to-br from-[hsl(38_75%_52%)] to-[hsl(25_80%_40%)]">
              {showLogo ? (
                <img
                  src={cachedLogo}
                  alt="Logo"
                  className="h-full w-full object-cover"
                  onError={() => setLogoError(true)}
                />
              ) : (
                <Boxes className="h-14 w-14 text-white scale-[1.35]" strokeWidth={1.75} />
              )}
            </div>
            <span
              className="text-[26px] font-bold tracking-tight text-[#1a1a1a]"
              style={{ fontFamily: "'Inter', ui-sans-serif, system-ui, sans-serif" }}
            >
              MM Wear
            </span>
            <span className="text-[9px] text-[#b0b0b0] mt-1 font-medium tracking-wide">
              Powered by Automystics
            </span>
          </div>

          {/* Form / content */}
          {children}
        </div>

        {/* Footer card */}
        {rightFooter && (
          <div className="bg-white border border-[#dbdbdb] rounded-sm px-10 py-4 text-center text-[14px] text-[#262626]">
            {rightFooter}
          </div>
        )}

        {/* Bottom copyright */}
        <p className="text-center text-[12px] text-[#8e8e8e] mt-2">
          © {new Date().getFullYear()} MM Wear ERP · Made in India
        </p>
      </div>
    </div>
  );
}
