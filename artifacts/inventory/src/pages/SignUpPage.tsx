import { useState, type FormEvent } from "react";
import { Link } from "wouter";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { customFetch, ApiError } from "@workspace/api-client-react";
import type { AuthAck } from "@workspace/api-client-react";
import { AuthShell } from "@/components/AuthShell";

const inputCls =
  "w-full bg-[#fafafa] border border-[#dbdbdb] rounded-[3px] text-[14px] px-3 py-2.5 placeholder:text-[#8e8e8e] focus:outline-none focus:border-[#a8a8a8] transition-colors";

export default function SignUpPage() {
  const [username, setUsername] = useState("");
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [done, setDone] = useState(false);
  const [submitting, setSubmitting] = useState(false);

  async function onSubmit(e: FormEvent) {
    e.preventDefault();
    setError(null);
    if (password.length < 8) {
      setError("Password must be at least 8 characters");
      return;
    }
    setSubmitting(true);
    try {
      await customFetch<AuthAck>("/api/auth/signup", {
        method: "POST",
        body: JSON.stringify({
          username,
          email,
          password,
          name: name.trim() || undefined,
        }),
      });
      setDone(true);
    } catch (err) {
      const apiErr = err as ApiError;
      const data = apiErr?.data as { error?: string } | undefined;
      setError(data?.error ?? "Sign-up failed");
    } finally {
      setSubmitting(false);
    }
  }

  if (done) {
    return (
      <AuthShell
        rightFooter={
          <span className="text-[14px] text-[#262626]">
            Already have an account?{" "}
            <Link href="/sign-in" className="font-semibold text-[hsl(38_80%_42%)] hover:text-[hsl(38_80%_35%)]" data-testid="link-signin">
              Log in
            </Link>
          </span>
        }
      >
        <div className="w-full text-center space-y-3">
          <p className="text-[15px] font-semibold text-[#262626]">Account created!</p>
          <p className="text-[13px] text-[#8e8e8e]">
            You can now log in with your username <span className="font-medium text-[#262626]">@{username}</span>.
          </p>
          <Link href="/sign-in" className="block mt-2 text-[13px] font-semibold text-[hsl(38_80%_42%)]">
            Go to login →
          </Link>
        </div>
      </AuthShell>
    );
  }

  return (
    <AuthShell
      rightFooter={
        <span className="text-[14px] text-[#262626]">
          Already have an account?{" "}
          <Link href="/sign-in" className="font-semibold text-[hsl(38_80%_42%)] hover:text-[hsl(38_80%_35%)]" data-testid="link-signin">
            Log in
          </Link>
        </span>
      }
    >
      <form onSubmit={onSubmit} className="w-full space-y-2" noValidate>
        {error && (
          <Alert variant="destructive" data-testid="signup-error" className="mb-3">
            <AlertDescription>{error}</AlertDescription>
          </Alert>
        )}

        <input
          id="signup-username"
          type="text"
          autoComplete="username"
          required
          placeholder="Username (letters, numbers, _)"
          value={username}
          onChange={(e) => setUsername(e.target.value)}
          data-testid="input-signup-username"
          className={inputCls}
        />
        <input
          id="signup-name"
          type="text"
          placeholder="Full name (optional)"
          value={name}
          onChange={(e) => setName(e.target.value)}
          data-testid="input-signup-name"
          className={inputCls}
        />
        <input
          id="signup-email"
          type="email"
          autoComplete="email"
          required
          placeholder="Email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          data-testid="input-signup-email"
          className={inputCls}
        />
        <input
          id="signup-password"
          type="password"
          autoComplete="new-password"
          required
          placeholder="Password (min 8 characters)"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          data-testid="input-signup-password"
          className={inputCls}
        />

        <button
          type="submit"
          disabled={submitting || !username || !email || !password}
          data-testid="btn-signup-submit"
          className="w-full mt-2 bg-[hsl(38_80%_48%)] hover:bg-[hsl(38_80%_42%)] disabled:opacity-50 disabled:cursor-not-allowed text-white font-semibold text-[14px] rounded-[8px] py-2 transition-colors"
        >
          {submitting ? "Creating account…" : "Sign up"}
        </button>

        <p className="text-center text-[11px] text-[#8e8e8e] pt-2">
          By signing up, you agree to our terms of service and privacy policy.
        </p>
      </form>
    </AuthShell>
  );
}
