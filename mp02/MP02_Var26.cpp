#include <iostream>
#include <semaphore>
#include <vector>
#include <thread>
#include <chrono>
#include <mutex>
#include <algorithm>
#include <random>
#include <string>

const int N = 5;
// Флаг, обозначающий, завершён ли обед
bool dinner_over = false;
std::mutex output_mutex;

// Генератор случаных чисел для определения количества 
// времени для размышления и подания пищи.
std::random_device randomizer;
std::mt19937 generator(randomizer());
std::uniform_int_distribution<int> distributor(1, 5);
// Бинарные семафоры для регулирования доступа к вилкам.
std::binary_semaphore* arr = new std::binary_semaphore[5]{
		std::binary_semaphore(1), std::binary_semaphore(1),
		std::binary_semaphore(1), std::binary_semaphore(1),
		std::binary_semaphore(1)
};

void philosopher(int id);
void think(int id);
void pick_up_forks(int id, int left_fork, int right_fork);
void eat(int id);
void put_down_forks(int id, int left_fork, int right_fork);

int main(int argc, char* argv[])
{
	if (argc != 2) {
		std::cout << "\nWrong number of arguments!\n" <<
			"Correct format: <exe-file> <time>\n";
		std::cout << "Please try again.\n";
		return -1;
	}
	// Количество секунд, которое философам будет выделено на обед.
	int seconds = 0;
	// Проверка количества секунд (входного параметра командной строки) на соответствие формату
	try {
		seconds = std::stoi(argv[1]);
	}
	catch (const std::invalid_argument& e) {
		std::cout << "\nCouldn't parse the number of seconds as the first command-line argument.\n";
		std::cout << "Correct format: integer number in range [5; 30].\n";
		std::cout << "Please try again.\n";
		return -1;
	}
	catch (const std::out_of_range& e) {
		std::cout << "\nNumber of seconds (1st argument) is out of integer range.\n";
		std::cout << "Correct format: integer number in range [5; 30].\n";
		std::cout << "Please try again.\n";
		return -1;
	}
	if (seconds < 5 || seconds > 30) {
		std::cout << "\nNumber of seconds is out of expected range [5; 30].\n";
		std::cout << "Correct format: integer number in range [5; 30].\n";
		std::cout << "Please try again.\n";
		return -1;
	}

	std::vector<std::thread> phils;
	// Заполняем вектор потоков (философов).
	for (int i = 0; i < N; i++)
	{
		phils.push_back(std::thread(philosopher, i));
	}
	// Главный поток спит заданное количество секунд.
	std::this_thread::sleep_for(std::chrono::seconds(seconds));
	// После прошествия заданного количества секунд
	// философам подаётся сигнал о завершении обеда.
	dinner_over = true;
	{
		std::lock_guard<std::mutex> cout_lock(output_mutex);
		std::cout << "Dinner's over!\n";
	}
	for (int i = 0; i < N; i++)
	{
		phils[i].join();
	}

	delete[] arr;
}

/// <summary>
/// Стандартный обеденный цикл философа.
/// </summary>
/// <param name="id">Номер философа, от 0 до 4 включительно.</param>
void philosopher(int id) {
	while (!dinner_over) {
		think(id);
		if (!dinner_over) {
			int left_fork = std::min(id, (id + 1) % N);
			int right_fork = std::max(id, (id + 1) % N);
			pick_up_forks(id, left_fork, right_fork);
			// К этому моменту у философа получилось взять обе вилки.
			// Философ начинает есть.
			eat(id);
			// После того, как философ поел, он кладёт обе вилки обратно.
			put_down_forks(id, left_fork, right_fork);
		}
	}
}

/// <summary>
/// Стандартный процесс размышления философа.
/// </summary>
/// <param name="id">Номер философа, от 0 до 4 включительно.</param>
void think(int id) {
	int time_to_ponder = distributor(generator);
	{
		std::lock_guard<std::mutex> cout_lock(output_mutex);
		std::cout << "Philosopher " << id << " is thinking for " << time_to_ponder << " seconds...\n";
	}
	// Философ размышляет случайное количество времени (от 1 до 5 секунд).
	std::this_thread::sleep_for(std::chrono::seconds(time_to_ponder));
}

/// <summary>
/// Процесс взятия философом вилок.
/// </summary>
/// <param name="id">Номер философа, от 0 до 4 включительно.</param>
/// <param name="left_fork">Номер наименьшей вилки философа (как правило, она левая).</param>
/// <param name="right_fork">Номер наибольшей вилки философа (как правило, она правая).</param>
void pick_up_forks(int id, int left_fork, int right_fork) {
	arr[left_fork].acquire();
	// Философ пробует взять свою вилку с меньшим номером.
	{
		std::lock_guard<std::mutex> cout_lock(output_mutex);
		std::cout << "Philosopher " << id << " picked up fork " << left_fork << ".\n";
	}
	// Философ пробует взять свою вилку с большим номером.
	arr[right_fork].acquire();
	{
		std::lock_guard<std::mutex> cout_lock(output_mutex);
		std::cout << "Philosopher " << id << " picked up fork " << right_fork << ".\n";
	}
}
/// <summary>
/// Процесс поедания философом спагетти.
/// </summary>
/// <param name="id">Номер философа, от 0 до 4 включительно.</param>
void eat(int id) {
	int time_to_eat = distributor(generator);
	// Если у философа получилось взять обе вилки, то он начинает есть.
	{
		std::lock_guard<std::mutex> cout_lock(output_mutex);
		std::cout << "Philosopher " << id << " is eating for " << time_to_eat << " seconds.\n";
	}
	// Философ ест случайное количество времени (от 1 до 5 секунд).
	std::this_thread::sleep_for(std::chrono::seconds(time_to_eat));
}

/// <summary>
/// Философ кладёт вилки обратно на стол.
/// </summary>
/// <param name="id">Номер философа, от 0 до 4 включительно.</param>
/// <param name="left_fork">Номер наименьшей вилки философа (как правило, она левая).</param>
/// <param name="right_fork">Номер наибольшей вилки философа (как правило, она правая).</param>
void put_down_forks(int id, int left_fork, int right_fork) {
	{
		std::lock_guard<std::mutex> cout_lock(output_mutex);
		std::cout << "Philosopher " << id << " has finished eating.\n";
	}
	// Философ кладёт свою вилку с меньшим номером.
	{
		std::lock_guard<std::mutex> cout_lock(output_mutex);
		std::cout << "Philosopher " << id << " put down fork " << left_fork << ".\n";
	}
	arr[left_fork].release();
	// Философ кладёт свою вилку с большим номером.
	{
		std::lock_guard<std::mutex> cout_lock(output_mutex);
		std::cout << "Philosopher " << id << " put down fork " << right_fork << ".\n";
	}
	arr[right_fork].release();
}