<?php

declare(strict_types=1);

namespace App\Controller;

use App\Dto\CreateReviewDto;
use App\Entity\Product;
use App\Entity\Review;
use App\Repository\ReviewRepository;
use Psr\Log\LoggerInterface;
use Symfony\Bridge\Doctrine\Attribute\MapEntity;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpKernel\Attribute\MapRequestPayload;
use Symfony\Component\ObjectMapper\ObjectMapperInterface;
use Symfony\Component\Routing\Attribute\Route;

#[Route('/api/good/products/{id}/review', name: 'api_products_review_create', methods: ['POST'])]
final class GoodController extends AbstractController
{
    public function __construct(
        private readonly ReviewRepository $reviewRepository,
        private readonly ObjectMapperInterface $objectMapper,
        private readonly LoggerInterface $logger,
    ) {
    }

    public function __invoke(
        #[MapEntity] Product $product,
        #[MapRequestPayload(
            acceptFormat: 'json',
            validationGroups: ['create'],
            validationFailedStatusCode: Response::HTTP_UNPROCESSABLE_ENTITY,
        )] CreateReviewDto $dto,
    ): JsonResponse {
        if (!$product->isReviewable()) {
            throw new \DomainException(sprintf(
                'Product of type "%s" cannot be reviewed.',
                get_debug_type($product),
            ));
        }

        /** @var Review $review */
        $review = $this->objectMapper->map($dto, Review::class);
        $review->assignToProduct($product);

        $this->reviewRepository->save($review, true);
        $this->logger->info('Review saved successfully.');

        return $this->json(['id' => $review->getId()], Response::HTTP_CREATED);
    }
}
