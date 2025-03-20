import * as React from "react";
import * as SwitchPrimitives from "@radix-ui/react-switch";
import { cn } from "~~/lib/utils";

const Switch = React.forwardRef<
  React.ElementRef<typeof SwitchPrimitives.Root>,
  React.ComponentPropsWithoutRef<typeof SwitchPrimitives.Root>
>(({ className, ...props }, ref) => (
  <SwitchPrimitives.Root className="SwitchRoot" id="airplane-mode" {...props} ref={ref}>
    <SwitchPrimitives.Thumb className="SwitchThumb" />
  </SwitchPrimitives.Root>
));
Switch.displayName = SwitchPrimitives.Root.displayName;

export { Switch };