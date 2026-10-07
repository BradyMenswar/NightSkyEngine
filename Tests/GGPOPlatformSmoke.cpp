// Standalone check for GGPO's macOS/POSIX backend (no Unreal SDK required).
#include "types.h"
#include <cassert>

int main()
{
    assert(Platform::GetProcessID() > 0);
    const uint32_t start = Platform::GetCurrentTimeMS();
    Platform::SleepMS(20);
    assert(static_cast<uint32_t>(Platform::GetCurrentTimeMS() - start) >= 10);

    HANDLE event = neosmart::CreateEvent(false, false);
    assert(event != nullptr);
    assert(neosmart::WaitForEvent(event, 0) == WAIT_TIMEOUT);
    assert(neosmart::SetEvent(event) == 0);
    assert(neosmart::WaitForEvent(event, 0) == 0);
    assert(neosmart::WaitForEvent(event, 0) == WAIT_TIMEOUT);
    assert(neosmart::DestroyEvent(event) == 0);
    return 0;
}
