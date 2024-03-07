# Standard Library
import datetime
from robot.api import logger
import cv2

def calculate_iterations(iterations_time):
    """
    :goal: calculates the number of iterations to be run
    :param iterations_time: the iteration time for all the run iterations
    :type iterations_time: list
    :return: None
    """
    total_iteration_time = 0

    for iteration_time in iterations_time:
        total_iteration_time += round(iteration_time.total_seconds())

    average_iteration_time = total_iteration_time / len(iterations_time)
    logger.info("\nAVERAGE ITERATION TIME: " +
                str(datetime.timedelta(seconds=round(average_iteration_time))))

    number_of_iterations_per_hour = round((3600 / average_iteration_time), 2)
    logger.info(f"NUMBER OF ITERATIONS PER HOUR: {number_of_iterations_per_hour}")

    # Time considered for the image update, setup and teardown of the test case.
    environment_setup_time = round(number_of_iterations_per_hour)

    number_of_iterations_per_night = round(number_of_iterations_per_hour * 16)
    logger.info(
        f"NUMBER OF RECOMMENDED ITERATIONS PER NIGHT: {number_of_iterations_per_night - environment_setup_time}"
    )

    number_of_iterations_per_weekend = round(number_of_iterations_per_hour * 60)
    logger.info(
        f"NUMBER OF RECOMMENDED ITERATIONS PER WEEKEND: {number_of_iterations_per_weekend - environment_setup_time}"
    )

def picture_webcam(path):
    try:
        cam = cv2.VideoCapture('/dev/video0')
        result, image = cam.read()
        if result:
            print("The image was detected")
            gray = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
            cv2.imwrite(path, gray)
        return True
    except Exception as e:
        print(str(e))
        print("No image detected. Please! try again")
        return False

