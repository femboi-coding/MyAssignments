#include "Heap.h"
#include <iostream>
#include <vector>

void printArray(const std::vector<int>& arr) {
    for (int num : arr) std::cout << num << " ";
    std::cout << std::endl;
}

int main() {
    std::vector<int> arr = {4, 10, 3, 5, 1};
    std::cout << "Оригінальний масив: ";
    printArray(arr);

    HeapSort(arr, true);
    std::cout << "Відсортований масив (MaxHeap): ";
    printArray(arr);

    HeapSort(arr, false);
    std::cout << "Відсортований масив (MinHeap): ";
    printArray(arr);

    return 0;
}

