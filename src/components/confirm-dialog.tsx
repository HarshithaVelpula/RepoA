import { useEffect, useState } from "react";
import { AlertTriangle } from "lucide-react";
import { AlertDialog, AlertDialogAction, AlertDialogCancel, AlertDialogContent, AlertDialogDescription, AlertDialogFooter, AlertDialogHeader, AlertDialogTitle } from "@/components/ui/alert-dialog";

type Req = { message: string; title: string; yes: string; resolve: (v: boolean) => void };
let push: ((r: Req) => void) | null = null;

/** Promise-based Yes/No popup (SweetAlert style). Falls back to window.confirm if the host is not mounted. */
export function askConfirm(message: string, opts?: { title?: string; yes?: string }): Promise<boolean> {
  if (!push) return Promise.resolve(window.confirm(message));
  return new Promise((resolve) => push!({ message, title: opts?.title ?? "Are you sure?", yes: opts?.yes ?? "Yes", resolve }));
}

export function ConfirmHost() {
  const [req, setReq] = useState<Req | null>(null);
  useEffect(() => { push = setReq; return () => { push = null; }; }, []);
  const close = (v: boolean) => { req?.resolve(v); setReq(null); };
  return <AlertDialog open={!!req} onOpenChange={(o) => { if (!o) close(false); }}>
    <AlertDialogContent className="max-w-md text-center">
      <AlertDialogHeader className="items-center text-center sm:text-center">
        <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-full border-4 border-destructive/30 text-destructive"><AlertTriangle className="h-8 w-8" /></div>
        <AlertDialogTitle className="text-xl">{req?.title}</AlertDialogTitle>
        <AlertDialogDescription className="whitespace-pre-line text-center">{req?.message}</AlertDialogDescription>
      </AlertDialogHeader>
      <AlertDialogFooter className="gap-2 sm:justify-center">
        <AlertDialogCancel onClick={() => close(false)}>No</AlertDialogCancel>
        <AlertDialogAction className="btn-danger" onClick={() => close(true)}>{req?.yes}</AlertDialogAction>
      </AlertDialogFooter>
    </AlertDialogContent>
  </AlertDialog>;
}
