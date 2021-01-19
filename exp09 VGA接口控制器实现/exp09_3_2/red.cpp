#include <iostream>
#include <fstream>
#include <iomanip>

const char* MIF_FILE = "red.mif";
const int MIF_SIZE = 4096;

int main() {
  std::ofstream red_pic(MIF_FILE);
  if (!red_pic.is_open()) {
    std::cout << "open error\n";
    return -1;
  }

  red_pic << "WIDTH = 12;\nDEPTH = " << MIF_SIZE << ";"
          << "\nADDRESS_RADIX = HEX;\nDATA_RADIX = HEX;\n\n"
          << "CONTENT BEGIN\n";

  for (int i = 0; i < MIF_SIZE; ++i) {
    red_pic << std::setw(8) << std::setfill('0') << std::hex
            << i << ": F00;\n";
  }
  red_pic << "END;";
  red_pic.close();

  return 0;
}