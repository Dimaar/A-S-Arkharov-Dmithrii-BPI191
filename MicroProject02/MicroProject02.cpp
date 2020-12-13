// Архаров Дмитрий Павлович
// БПИ191
// 3-ий Вариант.

#include <stdlib.h>
#include <stdio.h>
#include <thread>
#include <shared_mutex>
#include <ctime>
#include <iostream>
#include <vector>
#include <chrono>


using namespace std;

const int N = 10; // Размер базы данных
int Data[N]; // Используемая база данных (одномерный массив)  
shared_mutex RWlock; // Используем shared_mutex как реализацию ReadWriteLock, кроме того мьютекс это по сути семафор. 

void Reader(int num) // Функция для потоков читателей
{
    while (true) 
    {        
        shared_lock<shared_mutex> readlock(RWlock); // Устанавливаем shared_lock то есть совместное использование,позволяющее просматривать данные нескольким потокам одновременно
        int x = rand() % N; // Просматриваем случайную ячейку из базы данных
        int a = Data[x]; // Считываем данные из ячейки
        readlock.unlock(); // Снимаем наш shared_lock


        printf("Время %d | Читатель %d: Элемент[%d] Получен -> %d\n", clock(),num, x, a); // Выводим в консоль информацию о просмотренном вместе с временем
    }
}




void Writer(int num) // Функция для потоков писателей
{
    while (true) 
    {  
        unique_lock<shared_mutex> writelock(RWlock); // Устанавливаем unique_lock передающий исключительные полномочия нашему потоку писателю
        int x = rand() % N; // Выбираем случайную ячейку
        Data[x] = rand() % 10 + 1 + num; // Меняем её значение
        writelock.unlock(); // Снимаем unique_lock


        fprintf(stdout, "Время %d | Писатель %d: Элемент[%d] = % d\n", clock(), num, x, Data[x]); // Выводим в консоль информацию об изменении вместе с временем
    }
}



int main() 
{
    setlocale(LC_ALL, "Russian"); // This project uses russian language

    // Инциалиизация начальных данных :
    int numRead = -1, numWrite = -1;

    while (numRead < 0) // Не даём ввести отрицательное кол-во потоков, поскольку иначе всё сломается
    {
        cout << "Введи кол-во читателей (Больше или равно нуля) :";
        cin >> numRead;
    }
    while (numWrite < 0)
    {
        cout << "Введи кол-во писателей (Больше или равно нуля) :";
        cin >> numWrite;
    }

    for (int i = 0; i < N; i++)
    {
        Data[i] = 1;
    }

    // Инциализация потоков :
    vector <thread> Readers(numRead);
    for (int i = 0; i < numRead; i++)
    {
        Readers[i] = thread(Reader, i+1);
    }


    vector <thread> Writers(numWrite);
    for (int i = 0; i < numWrite; i++)
    {
        Writers[i] = thread(Writer, i+1);
    }

    // Join потоков :
    for (int i = 0; i < numRead; i++)
    {
        Readers[i].join();
    }
    for (int i = 0; i < numWrite; i++)
    {
        Writers[i].join();
    }
 

    return 0;
}
